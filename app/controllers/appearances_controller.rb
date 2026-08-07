# frozen_string_literal: true

class AppearancesController < ApplicationController
  def create
    image = Image.find_by(id: params[:image_id])
    return unless model_found?(image, "Image", params[:image_id], universes_url)
    return unless universe_visible_to_user?(image.universe)

    @appearance = image.appearances.build(allowed_appearance_params)
    flash[:error] = @appearance.errors.full_messages.join(", ") unless @appearance.save
    redirect_to edit_universe_image_url(image.universe, image)
  end

  def destroy
    @appearance = Appearance.find_by(id: params[:id])
    return unless model_found?(@appearance, "Image Tag", params[:id], universes_url)
    return unless universe_visible_to_user?(@appearance.universe)

    @appearance.destroy!
    redirect_to edit_universe_image_url(@appearance.character.universe.id, @appearance.image.id)
  end

  private

  def allowed_appearance_params
    params.expect(appearance: [:character_id])
  end
end
