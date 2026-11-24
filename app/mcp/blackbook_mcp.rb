# frozen_string_literal: true

# The MCP server: what a token's user may do on the site, as tools.
module BlackbookMcp
  # A message for the caller. Absent and inaccessible records give the same one.
  Refused = TailnetMcp::Refused

  # The sets are loaded here, so that the list does not depend on loading order.
  def self.tool_sets
    [UniverseTools, CharacterTools, ImageTools]
  end
end
