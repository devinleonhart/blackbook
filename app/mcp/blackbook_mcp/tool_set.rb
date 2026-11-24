# frozen_string_literal: true

module BlackbookMcp
  # A tool's block gets its arguments and the user's Access, and returns data.
  module ToolSet
    include TailnetMcp::ToolSet

    def paging
      { page: { type: "integer", minimum: 1 }, per_page: { type: "integer", minimum: 1, maximum: 100 } }
    end
  end
end
