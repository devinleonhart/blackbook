# frozen_string_literal: true

# Serves MCP. ActionController::Metal keeps Rails from parsing or logging the body, and
# leaves out sessions, cookies and Devise: only a token authorizes a request.
class McpController < ActionController::Metal
  MAX_BYTES = 4.megabytes
  BEARER = /\ABearer (\S+)\z/i
  METHODS = %w[initialize server/discover ping tools/list notifications/initialized].freeze

  def handle
    # Its nonce would start a session.
    request.content_security_policy = false
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    status, headers, body = respond_to_request
    log(status, body, started)
    self.status = status
    self.headers.merge!(headers)
    self.response_body = body
  end

  private

  def respond_to_request
    refuse_request || refuse_caller || serve
  end

  # Before anyone is authenticated, and without touching the body.
  def refuse_request
    return refusal(404, "Not found") if mcp_host.blank?
    return refusal(403, "Forbidden") unless host_allowed? && origin_allowed?

    refusal(405, "Method not allowed", "Allow" => "POST") unless request.request_method == "POST"
  end

  def refuse_caller
    return refusal(429, "Too many requests") if BlackbookMcp::Limits.failures_exceeded?(request.remote_ip)

    @token = McpToken.authenticate(request.headers["Authorization"].to_s.b[BEARER, 1]&.force_encoding(Encoding::UTF_8))
    if @token.nil?
      BlackbookMcp::Limits.count_failure(request.remote_ip)
      return refusal(401, "Unauthorized", "WWW-Authenticate" => "Bearer")
    end

    refusal(429, "Too many requests") unless BlackbookMcp::Limits.call_allowed?(@token)
  end

  def serve
    text = request.body.read(MAX_BYTES + 1).to_s
    return refusal(413, "Too large") if text.bytesize > MAX_BYTES

    @payload = parse(text)
    return refusal(400, "Invalid request") unless @payload.is_a?(Hash)

    @token.update_columns(last_used_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    transport.handle_request(Rack::Request.new(request.env.merge("rack.input" => StringIO.new(text))))
  end

  def parse(text)
    JSON.parse(text)
  rescue JSON::ParserError, EncodingError
    nil
  end

  # Stateless: a server and transport for each request, offering only what the token allows.
  def transport
    tools = BlackbookMcp.tools.select { |tool| @token.allows?(tool.scope) }.map(&:definition)
    server = MCP::Server.new(name: "blackbook", version: "1.0.0", tools: tools,
                             server_context: { access: BlackbookMcp::Access.new(@token.user) })
    MCP::Server::Transports::StreamableHTTPTransport.new(
      server, stateless: true, enable_json_response: true, serve_subscriptions_listen: false,
              dns_rebinding_protection: false, max_request_bytes: MAX_BYTES
    )
  end

  def mcp_host
    Rails.configuration.x.mcp_host
  end

  # The Host header itself. Rails' own host would believe X-Forwarded-Host, which anyone can send.
  def host_allowed?
    request.get_header("HTTP_HOST").to_s.b.sub(/:\d+\z/, "").casecmp?(mcp_host.b)
  end

  # Browsers send an Origin; other clients need not.
  def origin_allowed?
    origin = request.get_header("HTTP_ORIGIN")
    origin.nil? || URI.parse(origin).host.to_s.casecmp?(mcp_host)
  rescue URI::InvalidURIError
    false
  end

  def refusal(status, message, headers = {})
    [status, { "Content-Type" => "application/json" }.merge(headers), [JSON.generate(error: message)]]
  end

  def log(status, body, started)
    milliseconds = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
    Rails.logger.info(
      "mcp #{caller_facts} call=#{call} outcome=#{outcome(status, body)} duration=#{milliseconds}ms"
    )
  end

  def caller_facts
    return "token=- machine=- user=-" if @token.nil?

    "token=#{@token.id} machine=#{@token.machine.inspect} user=#{@token.user_id}"
  end

  # The name of a known tool or method, never text that a caller chose.
  def call
    return "-" unless @payload.is_a?(Hash)

    method = @payload["method"]
    return METHODS.include?(method) ? method : "unknown" unless method == "tools/call"

    params = @payload["params"]
    name = params["name"] if params.is_a?(Hash)
    BlackbookMcp.tools.map(&:name).include?(name) ? name : "unknown"
  end

  def outcome(status, body)
    return status unless status == 200

    answer = JSON.parse(body.join)
    answer["error"] || answer.dig("result", "isError") ? "error" : "ok"
  end
end
