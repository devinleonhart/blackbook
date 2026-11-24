# frozen_string_literal: true

# Calls /mcp as a client does.
module McpHelpers
  MCP_HOST = "lucky.example.ts.net"

  def issue_token(user, *scopes, machine: "cocoa")
    McpToken.issue!(user: user, machine: machine, scopes: scopes.presence || ["read"])
  end

  def mcp_post(body, token: nil, host: MCP_HOST, headers: {})
    all = { "Content-Type" => "application/json", "Accept" => "application/json, text/event-stream", "Host" => host }
    all["Authorization"] = "Bearer #{token}" if token
    post "/mcp", params: body.is_a?(String) ? body : body.to_json, headers: all.merge(headers)
  end

  def mcp_request(method, params = {}, **)
    mcp_post({ jsonrpc: "2.0", id: 1, method: method, params: params }, **)
    response.parsed_body
  end

  def call_tool(name, arguments = {}, token:)
    mcp_request("tools/call", { name: name, arguments: arguments }, token: token)
  end

  # The data of a successful call.
  def tool_data(name, arguments = {}, token:)
    body = call_tool(name, arguments, token: token)
    expect(body["error"] || body.dig("result", "isError")).to be_blank, body.inspect
    JSON.parse(body.dig("result", "content").sole.fetch("text"))
  end

  # The message of a refused call, whether the tool or the protocol refused it.
  def tool_error(name, arguments = {}, token:)
    body = call_tool(name, arguments, token: token)
    return body.dig("error", "message") if body["error"]

    expect(body.dig("result", "isError")).to be(true), body.inspect
    body.dig("result", "content").sole.fetch("text")
  end

  def tool_names(token)
    mcp_request("tools/list", token: token).dig("result", "tools").pluck("name")
  end

  def queries(&)
    list = []
    callback = ->(*, payload) { list << payload[:sql] unless payload[:name] == "SCHEMA" }
    ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &)
    list
  end
end

RSpec.shared_context "with MCP" do
  include McpHelpers

  let(:user) { create(:user) }
  let(:stranger) { create(:user) }
  let(:universe) { create(:universe, owner: user) }
  let(:foreign_universe) { create(:universe, owner: stranger) }
  let(:token) { issue_token(user, "read", "write", "delete") }
  let(:reader) { issue_token(user, "read") }
  let(:writer) { issue_token(user, "read", "write") }

  before do
    allow(Rails.configuration.x).to receive(:mcp_host).and_return(McpHelpers::MCP_HOST)
    BlackbookMcp::Limits.reset
  end
end
