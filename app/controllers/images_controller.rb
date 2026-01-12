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

    nil unless model_found?(@image, "Image", params[:id], universes_url)
  end

  def edit
    @image =
      Image
      .includes(image_tags: { character: :universe })
      .find_by(id: params[:id])

    return unless model_found?(@image, "Image", params[:id], universes_url)
    return unless universe_visible_to_user?(@image.universe)

    @favorited = @image.favorited_by?(current_user)
  end

  def create
    universe = Universe.find_by(id: params[:universe_id])
    return unless model_found?(universe, "Universe", params[:universe_id], universes_url)
    return unless universe_visible_to_user?(universe)

    image_files = extract_image_files
    return handle_empty_files(universe) if image_files.empty?

    created_images, errors = process_image_uploads(universe, image_files)
    handle_upload_result(universe, created_images, errors)
  end

  def update
    @image = Image.includes(image_tags: { character: :universe }).find_by(id: params[:id])
    return unless model_found?(@image, "Image", params[:id], universes_url)
    return unless universe_visible_to_user?(@image.universe)

    desired = ActiveModel::Type::Boolean.new.cast(allowed_image_update_params[:favorite])
    if desired
      ImageFavorite.find_or_create_by!(user: current_user, image: @image)
    else
      ImageFavorite.where(user: current_user, image: @image).destroy_all
    end

    redirect_to edit_universe_image_url(@image.universe, @image)
  end

  def view
    @image = Image.find(params[:id])
    image_data = @image.image_file.download

    response.headers["Content-Type"] = @image.image_file.content_type
    response.headers["Content-Length"] = image_data.bytesize.to_s
    response.headers["Cache-Control"] = "public, max-age=31536000"

    send_data image_data,
              type: @image.image_file.content_type,
              disposition: "inline",
              filename: @image.image_file.filename.to_s
  end

  def destroy
    @image = Image.find_by(id: params[:id])
    return unless model_found?(@image, "Image", params[:id], universes_url)
    return unless universe_visible_to_user?(@image.universe)

    @image.destroy!
    flash[:success] = "Image deleted!"
    redirect_to universe_url(@image.universe)
  end

  private

  def extract_image_files
    image_params = params.fetch(:image, {}).permit(image_file: [])
    image_file = image_params[:image_file]
    image_file = params[:image][:image_file] if image_file.blank? && params[:image].present?

    normalize_image_files(image_file)
  end

  def normalize_image_files(image_files)
    return [] if image_files.blank?

    files = image_files.is_a?(Array) ? image_files : [image_files]
    files.compact_blank
  end

  def handle_empty_files(universe)
    flash[:error] = "No images were selected."
    redirect_to universe_url(universe)
  end

  def process_image_uploads(universe, image_files)
    created_images = []
    errors = []

    image_files.each do |file|
      image = Image.new(universe_id: universe.id, image_file: file)
      if image.save
        created_images << image
      else
        errors.concat(image.errors.full_messages)
      end
    end

    [created_images, errors]
  end

  def handle_upload_result(universe, created_images, errors)
    if created_images.any?
      handle_successful_upload(universe, created_images, errors)
    else
      handle_failed_upload(universe, errors)
    end
  end

  def handle_successful_upload(universe, created_images, errors)
    if created_images.length == 1
      flash[:success] = "Image created!"
      redirect_to edit_universe_image_url(universe, created_images.first)
    else
      flash_message = "#{created_images.length} images created!"
      flash_message += " (#{errors.length} failed)" if errors.any?
      flash[:success] = flash_message
      redirect_to universe_url(universe)
    end
  end

  def handle_failed_upload(universe, errors)
    flash[:error] = errors.any? ? errors.join("\n") : "No images were uploaded."
    redirect_to universe_url(universe)
  end

  def allowed_image_update_params
    params.fetch(:image, {}).permit(:favorite)
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
