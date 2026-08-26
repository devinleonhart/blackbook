# frozen_string_literal: true

class ImagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:view]
  before_action :set_universe, only: [:create]
  before_action :set_image, only: [:edit, :update, :destroy]

  def random
    universe_ids = Universe.accessible_to(current_user).pluck(:id)

    scope = Image.where(universe_id: universe_ids)
    count = scope.count
    # Pick a random row by offset rather than sorting the whole table with
    # ORDER BY RANDOM(). `first` may return nil if a row is deleted between the
    # count and the fetch, which the guard below handles.
    image = scope.offset(rand(count)).first if count.positive?

    unless image
      flash[:notice] = "No images available yet."
      redirect_to root_path
      return
    end

    redirect_to edit_universe_image_url(image.universe, image)
  end

  def edit
    @favorited = @image.favorited_by?(current_user)
    @available_characters = @image.universe.characters - @image.characters
    @source_character = source_character(@image.universe)
  end

  def create
    image_files = extract_image_files
    character = tag_target_character

    if image_files.empty?
      respond_to do |format|
        format.html { handle_empty_files(@universe) }
        format.json { render json: { created: 0, error: "No images were selected." }, status: :unprocessable_content }
      end
      return
    end

    created_images, errors = process_image_uploads(@universe, image_files)
    tagged = tag_images(created_images, character)

    respond_to do |format|
      format.html { handle_upload_result(@universe, created_images, errors) }
      format.json { render json: { created: created_images.length, failed: errors.length, tagged: tagged } }
    end
  end

  def update
    desired = ActiveModel::Type::Boolean.new.cast(allowed_image_update_params[:favorite])
    if desired
      ImageFavorite.find_or_create_by!(user: current_user, image: @image)
    else
      ImageFavorite.where(user: current_user, image: @image).destroy_all
    end

    respond_to do |format|
      format.html { redirect_to edit_universe_image_url(@image.universe, @image) }
      format.json { render json: { favorited: desired } }
    end
  end

  def view
    @image = Image.find_by(id: params[:id])
    return head(:not_found) unless @image && url_filename_matches?(@image)

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
    universe = @image.universe
    character = source_character(universe)
    @image.destroy!
    flash[:success] = "Image deleted!"
    redirect_to(character ? character_url(character) : universe_url(universe))
  end

  private

  def source_character(universe)
    return nil if params[:character_id].blank?

    universe.characters.find_by(id: params[:character_id])
  end

  def set_universe
    @universe = Universe.find_by(id: params[:universe_id])
    return unless model_found?(@universe, "Universe", params[:universe_id], universes_url)

    universe_visible_to_user?(@universe)
  end

  def set_image
    @image = Image.includes(appearances: { character: :universe }).find_by(id: params[:id])
    return unless model_found?(@image, "Image", params[:id], universes_url)

    universe_visible_to_user?(@image.universe)
  end

  # The URL filename must match the stored UUID filename so the public `view`
  # endpoint can't be enumerated by sequential id alone.
  def url_filename_matches?(image)
    params[:filename] == image.image_file.filename.to_s
  end

  def tag_target_character
    return nil if params[:character_id].blank?

    @universe.characters.find_by(id: params[:character_id])
  end

  def tag_images(images, character)
    return 0 if character.nil?

    images.count { |image| image.appearances.create(character: character).persisted? }
  end

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
end
