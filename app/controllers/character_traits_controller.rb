# frozen_string_literal: true

class CharacterTraitsController < ApplicationController
  def index
    @character_traits =
      CharacterTrait
      .includes(:trait)
      .where(character_id: params[:character_id])
  end

  def create
    name = allowed_character_trait_params[:trait_name]

    if name.blank?
      error_and_redirect(
        "You must provide a name.",
        edit_character_url(params[:character_id])
      )
      return
    end

    ActiveRecord::Base.transaction do
      trait = Trait.find_or_create_by!(
        name: name
      )
      @character_trait = CharacterTrait.create!(
        character_id: params[:character_id], trait: trait
      )
    end
    redirect_to edit_character_url(@character_trait.character)
  end

  def destroy
    @character_trait = CharacterTrait.find_by(id: params[:id])
    return unless model_found?(@character_trait, "Character Trait", params[:id], universes_url)
    return unless universe_visible_to_user?(@character_trait.universe)

    @character_trait.destroy!
    redirect_to edit_character_url(@character_trait.character)
  end

  private

  def allowed_character_trait_params
    params.require(:character_trait).permit(:trait_name)
  end
end
