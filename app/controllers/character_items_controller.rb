# frozen_string_literal: true

class CharacterItemsController < ApplicationController
  def index
    @character_items =
      CharacterItem
      .includes(:item)
      .where(character_id: params[:character_id])
  end

  def create
    ActiveRecord::Base.transaction do
      item = Item.find_or_create_by!(name: allowed_character_item_params[:item_name])
      @character_item = CharacterItem.create!(character_id: params[:character_id], item: item)
    end
    redirect_to edit_character_url(@character_item.character)
  end

  def destroy
    @character_item = CharacterItem.find_by(id: params[:id])
    return unless model_found?(@character_item, "Character Item", params[:id], universes_url)
    return unless universe_visible_to_user?(@character_item.universe)
    @character_item.destroy!
    redirect_to edit_character_url(@character_item.character)
  end

  private

  def allowed_character_item_params
    params.require(:character_item).permit(:item_name)
  end
end
