# frozen_string_literal: true

module BlackbookMcp
  module UniverseTools
    extend ToolSet

    tool("list_universes", :read, "List the universes you own or collaborate on, with counts") do |_, access|
      Present.universes(access.universes.includes(:owner).order(:id).to_a, access.user)
    end

    tool("get_universe", :read, "Get a universe with its counts and its traits", { id: id }) do |input, access|
      universe = access.universe(input[:id])
      Present.universes([universe], access.user).first.merge(
        untagged_images: universe.images.untagged.count, traits: Present.trait_counts(universe)
      )
    end

    tool("list_traits", :read, "List a universe's traits, with how many characters have each",
         { universe_id: id }) do |input, access|
      Present.trait_counts(access.universe(input[:universe_id]))
    end
  end
end
