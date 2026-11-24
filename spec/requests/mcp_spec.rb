# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MCP", type: :request do
  include_context "with MCP"

  it "initializes" do
    result = mcp_request("initialize", { protocolVersion: "2025-06-18", capabilities: {},
                                         clientInfo: { name: "spec", version: "1" } }, token: reader)["result"]

    expect(result.dig("serverInfo", "name")).to eq("blackbook")
    expect(response.media_type).to eq("application/json")
    expect(response.headers.to_h.keys.map(&:downcase)).not_to include("mcp-session-id", "set-cookie")
  end

  it "accepts notifications" do
    mcp_post({ jsonrpc: "2.0", method: "notifications/initialized" }, token: reader)

    expect(response).to have_http_status(:accepted)
  end

  it "lists only tools the token may call" do
    expect(tool_names(reader)).to include("list_universes")
    expect(mcp_request("tools/list", token: reader).dig("result", "tools").first.dig("annotations", "readOnlyHint"))
      .to be(true)
  end

  it "lists universes the user owns or collaborates on, and no others" do
    universe.update!(name: "Owned")
    shared = create(:universe, owner: stranger, name: "Shared")
    create(:collaboration, user: user, universe: shared)
    create(:collaboration, user: create(:user), universe: shared)
    create(:character, universe: shared)
    create(:image, universe: shared)
    foreign_universe
    expected = [{ "id" => universe.id, "name" => "Owned", "owner" => user.display_name, "role" => "owner",
                  "characters" => 0, "images" => 0 },
                { "id" => shared.id, "name" => "Shared", "owner" => stranger.display_name, "role" => "collaborator",
                  "characters" => 1, "images" => 1 }]

    expect(tool_data("list_universes", token: reader)).to eq(expected)
    user.update!(admin: true)
    expect(tool_data("list_universes", token: reader)).to eq(expected)
  end

  it "records the last use" do
    freeze_time do
      mcp_request("tools/list", token: reader)

      expect(McpToken.authenticate(reader).last_used_at).to eq(Time.current)
    end
  end

  it "refuses unknown tools and arguments" do
    expect(tool_error("drop_universes", token: token)).to be_present
    expect(tool_error("list_universes", { owner_id: 1 }, token: token)).to be_present
  end

  it "hides unexpected errors" do
    allow(Universe).to receive(:accessible_to).and_raise(StandardError, "private detail")

    expect(tool_error("list_universes", token: token)).to eq("Internal error")
  end
end
