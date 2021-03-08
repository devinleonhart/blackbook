# frozen_string_literal: true

class CharacterItemsController < ApplicationController
  before_action lambda {
    character = Character.find_by(id: params[:character_id])
    raise MissingResource.new("character", params[:character_id]) if character.nil?

    require_universe_visible_to_user(
      "characters' items",
      character&.universe_id,
    )
  }, only: [:index, :create]

  def index
    @character_items =
      CharacterItem
      .includes(:item)
      .where(character_id: params[:character_id])
  end

  def create
    ActiveRecord::Base.transaction do
      item =
        Item.find_or_create_by!(name: allowed_character_item_params[:item_name])

      @character_item =
        CharacterItem.create!(character_id: params[:character_id], item: item)
    end
    redirect_to edit_character_url(@character_item.character)
  end

  def destroy
    @character_item = CharacterItem.find_by(id: params[:id])
    raise MissingResource.new("CharacterItem", params[:id]) if @character_item.nil?

    require_universe_visible_to_user(
      "characters' items",
      @character_item.universe.id,
    )

    @character_item.destroy!
    redirect_to edit_character_url(@character_item.character)
  end

  private

  def allowed_character_item_params
    params.require(:character_item).permit(:item_name)
  end
end
