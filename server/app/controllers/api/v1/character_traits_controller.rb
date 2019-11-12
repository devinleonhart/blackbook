# frozen_string_literal: true

class API::V1::CharacterTraitsController < API::V1::ApplicationController
  before_action -> { require_universe_visible_to_user("characters' traits") },
    only: [:index, :create]
  before_action lambda {
    require_resource_be_in_universe(
      Character,
      params[:character_id],
      params[:universe_id],
    )
  }, only: [:index, :create]

  def index
    @character_traits =
      CharacterTrait
      .includes(:trait)
      .where(character_id: params[:character_id])
  end

  def show
    @character_trait = CharacterTrait.includes(:trait).find_by(id: params[:id])
    if @character_trait.nil?
      raise MissingResource.new("CharacterTrait", params[:id])
    end

    require_universe_visible_to_user(
      "characters' traits",
      @character_trait.universe.id,
    )
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
  end

  def update
    @character_trait = CharacterTrait.includes(:trait).find_by(id: params[:id])
    if @character_trait.nil?
      raise MissingResource.new("CharacterTrait", params[:id])
    end

    require_universe_visible_to_user(
      "characters' traits",
      @character_trait.universe.id,
    )

    ActiveRecord::Base.transaction do
      trait = Trait.find_or_create_by!(
        name: allowed_character_trait_params[:trait_name]
      )
      @character_trait.update!(trait: trait)
    end
  end

  def destroy
    @character_trait = CharacterTrait.find_by(id: params[:id])
    if @character_trait.nil?
      raise MissingResource.new("CharacterTrait", params[:id])
    end

    require_universe_visible_to_user(
      "characters' traits",
      @character_trait.universe.id,
    )

    @character_trait.destroy!
    head :no_content
  end

  private

  def allowed_character_trait_params
    params.require(:character_trait).permit(:trait_name)
  end
end
