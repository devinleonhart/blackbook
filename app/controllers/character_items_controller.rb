# frozen_string_literal: true

class CharacterItemsController < ApplicationController
  before_action lambda {
    character = Character.find_by(id: params[:character_id])
    if character.nil?
      raise MissingResource.new("character", params[:character_id])
    end

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

  def show
    @character_item = CharacterItem.includes(:item).find_by(id: params[:id])
    if @character_item.nil?
      raise MissingResource.new("CharacterItem", params[:id])
    end

    require_universe_visible_to_user(
      "characters' items",
      @character_item.universe.id,
    )
  end

  def create
    ActiveRecord::Base.transaction do
      item =
        Item.find_or_create_by!(name: allowed_character_item_params[:item_name])

      @character_item =
        CharacterItem.create!(character_id: params[:character_id], item: item)
    end
    redirect_to @character_item.character
  end

  def update
    @character_item = CharacterItem.includes(:item).find_by(id: params[:id])
    if @character_item.nil?
      raise MissingResource.new("CharacterItem", params[:id])
    end

    require_universe_visible_to_user(
      "characters' items",
      @character_item.universe.id,
    )

    ActiveRecord::Base.transaction do
      item =
        Item.find_or_create_by!(name: allowed_character_item_params[:item_name])
      @character_item.update!(item: item)
    end
  end

  def destroy
    @character_item = CharacterItem.find_by(id: params[:id])
    if @character_item.nil?
      raise MissingResource.new("CharacterItem", params[:id])
    end

    require_universe_visible_to_user(
      "characters' items",
      @character_item.universe.id,
    )

    @character_item.destroy!
    redirect_to @character_item.character
  end

  private

  def allowed_character_item_params
    params.require(:character_item).permit(:item_name)
  end
end
