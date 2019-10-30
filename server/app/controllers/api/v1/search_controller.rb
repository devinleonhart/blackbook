# frozen_string_literal: true

class API::V1::SearchController < API::V1::ApplicationController
  before_action -> { require_universe_visible_to_user("models") }

  def multisearch
    matches =
      PgSearch
      .multisearch(params[:terms])
      .with_pg_search_highlight
      .flat_map { |match| props_for_match(match) }
      .each_with_object([]) do |props, models|
        duplicate_model = models.find { |model| model[:id] == props[:id] }
        if duplicate_model
          duplicate_model[:highlights].concat(props[:highlights])
        else
          models << props
        end
      end

    render json: { matches: matches }
  end

  private

  def props_for_match(match)
    api_models_for_match(match)
      .filter { |model| model.universe.id == params[:universe_id].to_i }
      .map do |model|
        {
          id: model.id,
          type: model.class.name,
          name: model.name,
          highlights: [match.pg_search_highlight],
        }
      end
  end

  def api_models_for_match(match)
    case match.searchable_type
    when "Character"
      [match.searchable]
    when "Location"
      [match.searchable]
    when "Item"
      match.searchable.characters
    when "Trait"
      match.searchable.characters
    when "Relationship"
      [match.searchable.originating_character]
    else
      raise <<~ERROR_MESSAGE.squish
        Unexpected model found by multisearch:
        #{match.searchable_type}.
      ERROR_MESSAGE
    end
  end
end
