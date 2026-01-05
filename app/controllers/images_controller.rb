# frozen_string_literal: true

class ImagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:view]

  def random
    universe_ids = accessible_universe_ids_for_user(current_user)

    image =
      Image
      .with_attached_image_file
      .where(universe_id: universe_ids)
      .order(Arel.sql("RANDOM()"))
      .first

    unless image
      render plain: "No images available.", status: :not_found
      return
    end

    image_data = image.image_file.download

    response.headers["Turbo-Visit-Control"] = "reload"
    response.headers["Content-Type"] = image.image_file.content_type
    response.headers["Content-Length"] = image_data.bytesize.to_s
    response.headers["Cache-Control"] = "no-store"

    send_data image_data,
              type: image.image_file.content_type,
              disposition: "inline",
              filename: image.image_file.filename.to_s
  end

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

    redirect_to edit_universe_image_url(@image.universe, @image)
  end

  def view
    @image = Image.find(params[:id])

    # Stream the image directly without redirecting
    image_data = @image.image_file.download

    response.headers['Content-Type'] = @image.image_file.content_type
    response.headers['Content-Length'] = image_data.bytesize.to_s
    response.headers['Cache-Control'] = 'public, max-age=31536000'

    send_data image_data,
              type: @image.image_file.content_type,
              disposition: 'inline',
              filename: @image.image_file.filename.to_s
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
    params.require(:image).permit(:image_file)
  end

  def allowed_image_update_params
    params.require(:image).permit(:favorite)
  end

  def accessible_universe_ids_for_user(user)
    owned_ids = Universe.where(owner: user).pluck(:id)
    collaborated_ids =
      Universe
      .joins(:collaborations)
      .where(collaborations: { user_id: user.id })
      .pluck(:id)

    (owned_ids + collaborated_ids).uniq
  end
end
