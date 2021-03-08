# frozen_string_literal: true

class CharacterTraitsController < ApplicationController
  before_action lambda {
    character = Character.find_by(id: params[:character_id])
    raise MissingResource.new("character", params[:character_id]) if character.nil?

    require_universe_visible_to_user(
      "characters' traits",
      character&.universe_id,
    )
  }, only: [:index, :create]

  def index
    @character_traits =
      CharacterTrait
      .includes(:trait)
      .where(character_id: params[:character_id])
  end

  def create
    ActiveRecord::Base.transaction do
      trait = Trait.find_or_create_by!(
        name: allowed_character_trait_params[:trait_name]
      )
      @character_trait = CharacterTrait.create!(
        character_id: params[:character_id], trait: trait
      )
    end
    redirect_to edit_character_url(@character_trait.character)
  end

  def destroy
    @character_trait = CharacterTrait.find_by(id: params[:id])
    raise MissingResource.new("CharacterTrait", params[:id]) if @character_trait.nil?

    require_universe_visible_to_user(
      "characters' traits",
      @character_trait.universe.id,
    )

    @character_trait.destroy!
    redirect_to edit_character_url(@character_trait.character)
  end

  private

  def allowed_character_trait_params
    params.require(:character_trait).permit(:trait_name)
  end
end
