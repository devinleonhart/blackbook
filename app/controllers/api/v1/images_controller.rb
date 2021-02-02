# frozen_string_literal: true

class API::V1::ImagesController < API::V1::ApplicationController
  def show
    @image =
      Image
      .includes(image_tags: { character: :universe })
      .find_by(id: params[:id])
    raise MissingResource.new("image", params[:id]) if @image.nil?
  end

  def create
    @image = Image.create!(allowed_image_create_params)
  end

  def update
    @image =
      Image
      .includes(image_tags: { character: :universe })
      .find_by(id: params[:id])
    raise MissingResource.new("image", params[:id]) if @image.nil?

    @image.update!(allowed_image_update_params)
  end

  def destroy
    @image = Image.find_by(id: params[:id])
    raise MissingResource.new("image", params[:id]) if @image.nil?

    @image.destroy!
    head :no_content
  end

  private

  def allowed_image_create_params
    params.require(:image).permit(:caption, :image_file)
  end

  def allowed_image_update_params
    params.require(:image).permit(:caption)
  end
end
