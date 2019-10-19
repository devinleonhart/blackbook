# frozen_string_literal: true

class API::V1::CharactersController < API::V1::ApplicationController
  before_action -> { require_universe_visible_to_user("character") },
    only: [:index, :create]

  def index
    @characters = Character.where(universe_id: params[:universe_id]).all
  end

  def show
    @character = Character.find_by(id: params[:id])
    raise MissingResource.new("character", params[:id]) if @character.nil?

    require_universe_visible_to_user("character", @character.universe.id)
  end

  def create
    properties =
      allowed_character_params.merge(universe_id: params[:universe_id])
    @character = Character.create!(properties)
  end

  def update
    @character = Character.find_by(id: params[:id])
    raise MissingResource.new("character", params[:id]) if @character.nil?

    require_universe_visible_to_user("character", @character.universe.id)

    @character.update!(allowed_character_params)
  end

  def destroy
    @character = Character.find_by(id: params[:id])
    raise MissingResource.new("character", params[:id]) if @character.nil?

    require_universe_visible_to_user("character", @character.universe.id)

    @character.destroy!
    head :no_content
  end

  private

  def allowed_character_params
    params.require(:character).permit(:name, :description)
  end
end
