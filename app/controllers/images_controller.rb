# frozen_string_literal: true

class ImagesController < ApplicationController
  def show
    @image =
      Image
      .includes(image_tags: { character: :universe })
      .find_by(id: params[:id])

    return unless model_found?(@image, "Image", params[:id], universes_url)
  end

  def create
    properties = allowed_image_create_params.merge(universe_id: params[:universe_id])
    @image = Image.new(properties)
    if @image.save
      flash[:success] = "Image created!"
      redirect_to edit_universe_image_url(params[:universe_id], @image)
    else
      flash[:error] = @image.errors.full_messages.join("\n")
      redirect_to universe_url(params[:universe_id])
    end
  end

  def edit
    @image =
      Image
      .includes(image_tags: { character: :universe })
      .find_by(id: params[:id])

    return unless model_found?(@image, "Image", params[:id], universes_url)
    return unless universe_visible_to_user?(@image.universe)
  end

  def update
    @image = Image.includes(image_tags: { character: :universe }).find_by(id: params[:id])
    return unless model_found?(@image, "Image", params[:id], universes_url)

    @image.update!(allowed_image_update_params)
    redirect_to edit_universe_image_url(@image)
  end

  def destroy
    @image = Image.find_by(id: params[:id])
    return unless model_found?(@image, "Image", params[:id], universes_url)

    @image.destroy!
    flash[:success] = "Image deleted!"
    redirect_to universe_url(@image.universe)
  end

  private

  def allowed_image_create_params
    params.require(:image).permit(:caption, :image_file)
  end

  def allowed_image_update_params
    params.require(:image).permit(:caption, :avatar, :universe_avatar)
  end
end
