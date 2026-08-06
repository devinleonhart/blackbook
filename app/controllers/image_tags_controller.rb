# frozen_string_literal: true

class ImageTagsController < ApplicationController
  def create
    image = Image.find_by(id: params[:image_id])
    return unless model_found?(image, "Image", params[:image_id], universes_url)
    return unless universe_visible_to_user?(image.universe)

    @image_tag = image.image_tags.build(allowed_image_tag_params)
    flash[:error] = @image_tag.errors.full_messages.join(", ") unless @image_tag.save
    redirect_to edit_universe_image_url(image.universe, image)
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
    params.expect(image_tag: [:character_id])
  end
end
