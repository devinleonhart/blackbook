# frozen_string_literal: true

class ImagesController < ApplicationController
  def show
    @image =
      Image
      .includes(image_tags: { character: :universe })
      .find_by(id: params[:id])
    raise MissingResource.new("image", params[:id]) if @image.nil?
  end

  def create
    properties =
      allowed_image_create_params.merge(universe_id: params[:universe_id])
    @image = Image.create!(properties)
    flash[:success] = "Image created!"
    redirect_to universe_url(params[:universe_id])
  end

  def edit
    @select_options = ["Cheese?", "Please!"]
    @image =
      Image
      .includes(image_tags: { character: :universe })
      .find_by(id: params[:id])
    raise MissingResource.new("image", params[:id]) if @image.nil?
  end

  def update
    @image =
      Image
      .includes(image_tags: { character: :universe })
      .find_by(id: params[:id])
    raise MissingResource.new("image", params[:id]) if @image.nil?

    @image.update!(allowed_image_update_params)
    redirect_to edit_universe_image_url(@image)
  end

  def destroy
    @image = Image.find_by(id: params[:id])
    raise MissingResource.new("image", params[:id]) if @image.nil?

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
