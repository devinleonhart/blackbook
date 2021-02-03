# frozen_string_literal: true

class ImageTagsController < ApplicationController
  def show
    @image_tag =
      ImageTag
      .includes(:character, :image)
      .find_by(id: params[:id])

    raise MissingResource.new("image_tag", params[:id]) if @image_tag.nil?

    require_universe_visible_to_user(
      "characters' images",
      @image_tag.universe.id,
    )
  end

  def create
    properties =
      allowed_image_tag_params.merge(image_id: params[:image_id])

    character_id = params.dig(:image_tag, :character_id)
    character = Character.find_by(id: character_id)
    raise MissingResource.new("character", character_id) if character.nil?

    require_universe_visible_to_user(
      "characters' images",
      character.universe.id,
    )

    @image_tag = ImageTag.create! properties
  end

  def destroy
    @image_tag = ImageTag.find_by(id: params[:id])
    raise MissingResource.new("image_tag", params[:id]) if @image_tag.nil?

    require_universe_visible_to_user(
      "characters' images",
      @image_tag.universe.id,
    )

    @image_tag.destroy!
    head :no_content
  end

  private

  def allowed_image_tag_params
    params.require(:image_tag).permit(:character_id)
  end
end
