# frozen_string_literal: true

module BlackbookMcp
  # Defines tools. A tool's block gets its arguments and the user's Access, and returns data.
  module ToolSet
    Tool = Data.define(:name, :scope, :definition)

    def tools
      @tools ||= []
    end

    def tool(name, scope, description, properties = {}, required: properties.keys, &block)
      definition = MCP::Tool.define(
        name: name, description: description, annotations: annotations_for(scope),
        input_schema: { type: "object", properties: properties, required: required.map(&:to_s),
                        additionalProperties: false }
      ) { |server_context:, **arguments| ToolSet.respond { block.call(arguments, server_context[:access]) } }
      tools << Tool.new(name: name, scope: scope, definition: definition)
    end

    def annotations_for(scope)
      { read_only_hint: scope == :read, destructive_hint: scope == :delete, open_world_hint: false }
    end

    def id = { type: "integer", minimum: 1 }
    def text = { type: "string", maxLength: 255 }
    def flag = { type: "boolean" }

    def paging
      { page: { type: "integer", minimum: 1 }, per_page: { type: "integer", minimum: 1, maximum: 100 } }
    end

    def self.respond
      result(yield)
    rescue Refused => error
      failure(error.message)
    rescue ActiveRecord::RecordInvalid => error
      failure(error.record.errors.full_messages.join(", "))
    rescue StandardError => error
      # Its message may hold what was sent.
      Rails.logger.error("mcp tool failed: #{error.class} at #{error.backtrace&.first}")
      failure("Internal error")
    end

    def self.result(data)
      MCP::Tool::Response.new([{ type: "text", text: JSON.generate(data) }])
    end

    def self.failure(message)
      MCP::Tool::Response.new([{ type: "text", text: message }], error: true)
    end
  end
end
