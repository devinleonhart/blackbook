# frozen_string_literal: true

class AppearancesController < ApplicationController
  def create
    image = Image.find_by(id: params[:image_id])
    return unless model_found?(image, "Image", params[:image_id], universes_url)
    return unless universe_visible_to_user?(image.universe)

    added = image.tag_characters(submitted_character_ids)

    @image = image
    @available_characters = image.universe.characters - image.characters

    respond_to do |format|
      format.turbo_stream
      format.html do
        flash[:success] = "Added #{helpers.pluralize(added, 'character')}." if added.positive?
        redirect_to edit_universe_image_url(image.universe, image)
      end
    end
  end

  def destroy
    @appearance = Appearance.find_by(id: params[:id])
    return unless model_found?(@appearance, "Image Tag", params[:id], universes_url)
    return unless universe_visible_to_user?(@appearance.universe)

    @appearance.destroy!
    @image = @appearance.image
    @available_characters = @image.universe.characters - @image.characters

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to edit_universe_image_url(@image.universe, @image) }
    end
  end

  private

  def submitted_character_ids
    raw = Array(params[:character_ids]) + [params.dig(:appearance, :character_id)]
    raw.filter_map { |value| Integer(value, 10, exception: false) }.uniq
  end
end
