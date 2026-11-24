# frozen_string_literal: true

# Each token acts as a user.
ActiveSupport.on_load(:tailnet_mcp_token) { belongs_to :user, inverse_of: :mcp_tokens }

TailnetMcp.configure do |config|
  config.name = "blackbook"
  config.token_prefix = "bbk"
  # The only host that may be used for MCP. Without it, /mcp does not exist.
  config.host = ENV["MCP_HOST"].presence
  config.tool_sets = -> { BlackbookMcp.tool_sets }
  config.context = ->(token) { BlackbookMcp::Access.new(token.user) }
  config.token_attributes = lambda do |variables|
    email = variables["USER"].to_s.strip.downcase
    { user: User.find_by(email: email) || raise(TailnetMcp::Refused, "No user has the email in USER") }
  end
  config.list_facts = ->(token) { [token.user.email] }
  config.log_facts = ->(token) { { user: token.user_id } }
end
