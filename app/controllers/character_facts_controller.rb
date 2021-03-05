# frozen_string_literal: true

class CharacterFactsController < ApplicationController
  def create
    properties =
      allowed_character_fact_params.merge(character_id: params[:character_id])
    @fact = Fact.create!(properties)
    redirect_to character_url(@fact.character)
  end

  def destroy
    @fact = Fact.find_by(id: params[:id])
    raise MissingResource.new("fact", params[:id]) if @fact.nil?

    require_universe_visible_to_user("fact", @fact.character.universe.id)

    @fact.destroy!
    redirect_to character_url(@fact.character)
  end

  private

  def allowed_character_fact_params
    params.require(:fact).permit(:fact_type, :content)
  end
end
