# frozen_string_literal: true

class ImageTagsController < ApplicationController
  def show
    @image_tag = ImageTag.includes(:character, :image).find_by(id: params[:id])
    return unless model_found?(@image_tag, "Image Tag", params[:id], universes_url)
    return unless universe_visible_to_user?(@image_tag.universe)
  end

  def create
    properties = allowed_image_tag_params.merge(image_id: params[:image_id])
    character_id = params.dig(:image_tag, :character_id)
    character = Character.find_by(id: character_id)
    @image_tag = ImageTag.create!(properties)
    return unless model_found?(@image_tag, "Image Tag", params[:id], universes_url)
    return unless universe_visible_to_user?(@image_tag.universe)

    redirect_to edit_universe_image_url(character.universe.id, params[:image_id])
  end

  def destroy
    @image_tag = ImageTag.find_by(id: params[:id])
    return unless model_found?(@image_tag, "Image Tag", params[:id], universes_url)
    return unless universe_visible_to_user?(@image_tag.universe)

    @image_tag.destroy!
    redirect_to edit_universe_image_url(@image_tag.character.universe.id, @image_tag.image.id)
  end

  private

  def allowed_image_tag_params
    params.require(:image_tag).permit(:character_id)
  end
end
