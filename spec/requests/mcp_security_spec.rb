# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MCP security", type: :request do
  include_context "with MCP"

  let(:list) { { jsonrpc: "2.0", id: 1, method: "tools/list" } }

  def status(body = list, **)
    mcp_post(body, **)
    response.status
  end

  describe "authentication" do
    it "refuses anything but a live token, with one answer" do
      expired = issue_token(user)
      TailnetMcp::Token.authenticate(expired).update!(expires_at: 1.second.ago)
      revoked = issue_token(user)
      TailnetMcp::Token.authenticate(revoked).revoke!
      headers = [nil, "", "Bearer", "Bearer ", "Bearer wrong", "Bearer #{expired}", "Bearer #{revoked}", reader,
                 "Basic #{reader}", "Token #{reader}", "Bearer  #{reader}", "Bearer #{reader} x", "Bearer \xFF"]

      answers = headers.map do |value|
        mcp_post(list, headers: value ? { "Authorization" => value } : {})
        [response.status, response.body, response.headers["WWW-Authenticate"]]
      end

      expect(answers.uniq).to eq([[401, '{"error":"Unauthorized"}', "Bearer"]])
    end

    it "accepts the scheme in any case" do
      mcp_post(list, headers: { "Authorization" => "bearer #{reader}" })

      expect(response).to have_http_status(:ok)
    end

    it "does not accept a session cookie" do
      sign_in(user)

      expect(status).to eq(401)
    end

    it "does not accept the Discord import token" do
      old = ENV.fetch("DISCORD_IMPORT_TOKEN", nil)
      ENV["DISCORD_IMPORT_TOKEN"] = "import"

      expect(status(token: "import")).to eq(401)
    ensure
      ENV["DISCORD_IMPORT_TOKEN"] = old
    end

    it "does not accept a token in the address or the body" do
      post "/mcp?token=#{reader}&access_token=#{reader}", params: list.merge(token: reader).to_json,
                                                          headers: { "Host" => McpHelpers::MCP_HOST }

      expect(response).to have_http_status(:unauthorized)
    end

    it "is of no use elsewhere" do
      get "/universes", headers: { "Authorization" => "Bearer #{reader}" }

      expect(response).to redirect_to(new_user_session_url)
    end
  end

  describe "host and origin" do
    it "answers only its host" do
      ["blackbook.devleo.me", "localhost", "127.0.0.1", "#{McpHelpers::MCP_HOST}.evil.example",
       "x#{McpHelpers::MCP_HOST}", "evil.example:8443"].each do |host|
        expect(status(host: host, token: reader)).to eq(403), host
      end
      expect(status(host: "#{McpHelpers::MCP_HOST}:8443", token: reader)).to eq(200)
      expect(status(host: McpHelpers::MCP_HOST.upcase, token: reader)).to eq(200)
    end

    it "does not believe forwarding headers" do
      %w[X-Forwarded-Host X-Forwarded-Server X-Original-Host Forwarded].each do |name|
        value = name == "Forwarded" ? "host=#{McpHelpers::MCP_HOST}" : McpHelpers::MCP_HOST
        expect(status(host: "blackbook.devleo.me", token: reader, headers: { name => value })).to eq(403)
      end
    end

    it "refuses foreign origins" do
      ["https://evil.example", "null", "https://blackbook.devleo.me", "http://localhost", "nonsense", "http://[",
       "https://#{McpHelpers::MCP_HOST}.evil.example", "file://"].each do |origin|
        expect(status(token: reader, headers: { "Origin" => origin })).to eq(403), origin
      end
      expect(status(token: reader, headers: { "Origin" => "https://#{McpHelpers::MCP_HOST}:8443" })).to eq(200)
    end

    it "does not exist without a configured host" do
      [nil, ""].each do |host|
        allow(TailnetMcp.configuration).to receive(:host).and_return(host)

        expect(status(token: reader)).to eq(404)
        expect(status(host: "", token: reader)).to eq(404)
      end
    end

    it "takes only POST" do
      headers = { "Host" => McpHelpers::MCP_HOST, "Authorization" => "Bearer #{reader}" }
      %i[get delete put patch options head].each do |verb|
        public_send(verb, "/mcp", headers: headers)

        expect(response).to have_http_status(:method_not_allowed)
        expect(response.headers["Allow"]).to eq("POST")
      end
    end

    it "reads no universe when it refuses" do
      reader
      refused = queries do
        status
        status(token: "bbk_#{'x' * 43}")
        status(host: "evil.example", token: reader)
        status(token: reader, headers: { "Origin" => "https://evil.example" })
        status("x" * 5.megabytes, token: reader)
      end

      expect(refused.grep(/universes/)).to be_empty
    end
  end

  describe "limits" do
    it "limits calls for each token" do
      freeze_time
      expect(Array.new(120) { status(token: reader) }.uniq).to eq([200])
      expect(status(token: reader)).to eq(429)
      expect(status(token: writer)).to eq(200)
      travel 61.seconds
      expect(status(token: reader)).to eq(200)
    end

    it "limits failures for each address" do
      freeze_time
      expect(Array.new(20) { status(token: "wrong") }.uniq).to eq([401])
      expect(status(token: "wrong")).to eq(429)
      expect(status(token: "wrong", headers: { "REMOTE_ADDR" => "203.0.113.9" })).to eq(401)
      travel 61.seconds
      expect(status(token: "wrong")).to eq(401)
    end

    it "does not count successes as failures" do
      25.times { status(token: reader) }

      expect(status(token: "wrong")).to eq(401)
    end
  end

  describe "bodies" do
    it "refuses malformed ones without an exception" do
      ["", "{", "null", "3", '"x"', "[]", "[1]", "{}", '{"jsonrpc":"2.0"}', "\xFF", ("[" * 2000)].each do |body|
        mcp_post(body, token: reader)

        expect(response.status).to be_between(200, 499), body
        expect(response.media_type).to eq("application/json")
        expect(response.parsed_body.to_s).not_to include("Exception", "app/")
      end
    end

    it "refuses large ones" do
      expect(status("x" * (4.megabytes + 1), token: reader)).to eq(413)
    end
  end

  describe "log" do
    let(:log) { StringIO.new }

    around do |example|
      logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(log, level: :info))
      old = Rails.logger
      Rails.logger = logger
      ActionController::Base.logger = logger
      ActiveRecord::Base.logger = logger
      example.run
    ensure
      Rails.logger = old
      ActionController::Base.logger = old
      ActiveRecord::Base.logger = old
    end

    def lines
      log.string.lines.grep(/\bmcp /)
    end

    it "has one line for a call, with its facts" do
      record = TailnetMcp::Token.authenticate(reader)
      call_tool("list_universes", token: reader)

      expect(lines.sole).to match(
        /mcp token=#{record.id} machine="cocoa" user=#{user.id} call=list_universes outcome=ok duration=\d+ms$/
      )
    end

    it "tells refusals and errors apart" do
      call_tool("list_universes", { secret: "argument-value" }, token: reader)
      call_tool("nothing\nmcp token=1", {}, token: reader)
      mcp_request("tools/list", token: reader)
      status(token: "wrong")
      status(host: "evil.example", token: reader)

      expect(lines.size).to eq(5)
      expect(lines.map { |line| line[/call=(\S+)/, 1] }).to eq(%w[list_universes unknown tools/list - -])
      expect(lines.map { |line| line[/outcome=(\S+)/, 1] }).to eq(%w[error error ok 401 403])
    end

    it "keeps machine names on one line" do
      odd = issue_token(user, machine: "a\nmcp token=99")
      call_tool("list_universes", token: odd)

      expect(lines.size).to eq(1)
    end

    it "holds no token, digest or argument" do
      call_tool("list_universes", { secret: "argument-value" }, token: reader)
      call_tool("list_universes", {}, token: reader)
      status("{\"broken\": \"argument-value\"", token: reader)
      status(token: "#{reader}x")
      status(token: reader.chop)
      status(token: reader, host: "evil.example")
      allow(Universe).to receive(:accessible_to).and_raise(StandardError, "argument-value")
      call_tool("list_universes", {}, token: reader)

      expect(log.string).to include("StandardError")
      expect(log.string).not_to include(reader.delete_prefix("bbk_").chop, TailnetMcp::Token.authenticate(reader).digest)
      expect(log.string).not_to include("argument-value")
    end
  end

  it "sets no cookie, also when it refuses" do
    [{ token: reader }, {}, { host: "evil.example" }].each do |options|
      status(**options)

      expect(response.headers["Set-Cookie"]).to be_nil
    end
  end
end
