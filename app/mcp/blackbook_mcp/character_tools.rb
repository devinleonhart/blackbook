# frozen_string_literal: true

module BlackbookMcp
  module CharacterTools
    extend ToolSet

    def self.like(part)
      "%#{Character.sanitize_sql_like(part)}%"
    end

    tool("list_characters", :read, "List characters by name, optionally of one universe, with part of a name, " \
                                   "or with a trait. Paged, 50 at a time",
         { universe_id: id, name: text, trait: text, **paging }, required: []) do |input, access|
      scope = access.characters
      scope = access.universe(input[:universe_id]).characters if input[:universe_id]
      scope = scope.where("characters.name ILIKE ?", like(input[:name])) if input[:name]
      scope = scope.where(id: Trait.where(name: input[:trait]).select(:character_id)) if input[:trait]
      Page.of(scope.includes(:traits).order(:name, :id), input) { |list| Present.characters(list) }
    end

    tool("get_character", :read, "Get a character with its traits and their ids", { id: id }) do |input, access|
      Present.character(access.character(input[:id]))
    end

    tool("create_character", :write, "Create a character in a universe",
         { universe_id: id, name: text }) do |input, access|
      Present.character(access.universe(input[:universe_id]).characters.create!(name: input[:name]))
    end

    tool("update_character", :write, "Rename a character", { id: id, name: text }) do |input, access|
      Present.character(access.character(input[:id]).tap { |character| character.update!(name: input[:name]) })
    end

    tool("add_trait", :write, "Add a trait to a character", { character_id: id, name: text }) do |input, access|
      Present.trait(access.character(input[:character_id]).traits.create!(name: input[:name]))
    end

    tool("update_trait", :write, "Rename a trait of one character", { id: id, name: text }) do |input, access|
      Present.trait(access.trait(input[:id]).tap { |trait| trait.update!(name: input[:name]) })
    end

    tool("delete_character", :delete, "Delete a character and its traits. Its images remain",
         { id: id }) do |input, access|
      access.character(input[:id]).destroy!
      { deleted: true, id: input[:id] }
    end

    tool("delete_trait", :delete, "Delete a trait from its character", { id: id }) do |input, access|
      access.trait(input[:id]).destroy!
      { deleted: true, id: input[:id] }
    end
  end
end
