# frozen_string_literal: true

class SlideshowsController < ApplicationController
  def show
    universe_ids = Universe.accessible_to(current_user).pluck(:id)
    @mode = slideshow_mode
    @universe_id = selected_universe_id!(universe_ids)
    @character_ids = selected_character_ids
    @universes = Universe.where(id: universe_ids).order(Arel.sql("LOWER(universes.name) ASC"))

    # The character picker only makes sense within a single universe, where the
    # list is bounded and names are unambiguous.
    @characters = @universe_id ? Character.where(universe_id: @universe_id).order(:name) : Character.none

    scoped_universe_ids = @universe_id ? [@universe_id] : universe_ids
    @has_images = slideshow_images_scope(scoped_universe_ids).limit(1).exists?
  end

  def images
    universe_ids = Universe.accessible_to(current_user).pluck(:id)
    @mode = slideshow_mode
    universe_id = selected_universe_id!(universe_ids)
    scoped_universe_ids = universe_id ? [universe_id] : universe_ids

    images =
      slideshow_images_scope(scoped_universe_ids)
      .with_attached_image_file
      .includes(:characters)
      .limit(5000)
      .to_a
      .shuffle

    favorited_ids = ImageFavorite.where(user: current_user, image_id: images.map(&:id)).pluck(:image_id).to_set

    slides = images.map do |img|
      {
        id: img.id,
        url: view_image_path(img.id, img.image_file.filename.to_s),
        detail_url: edit_universe_image_path(img.universe_id, img.id),
        favorite_url: universe_image_path(img.universe_id, img.id),
        favorited: favorited_ids.include?(img.id),
        characters: img.characters.map(&:name).sort
      }
    end

    render json: { slides: slides }
  end

  private

  def slideshow_mode
    mode = params[:mode].to_s.downcase
    return "favorites" if mode == "favorites"

    "all"
  end

  def selected_universe_id!(allowed_universe_ids)
    raw = params[:universe_id].to_s
    return nil if raw.blank?

    id = Integer(raw, 10)
    raise ActiveRecord::RecordNotFound unless allowed_universe_ids.include?(id)

    id
  rescue ArgumentError
    raise ActiveRecord::RecordNotFound
  end

  # Character ids to cycle through. Accepts an array or a comma-separated string;
  # non-numeric values are ignored. Ids outside the user's accessible images
  # simply match nothing, so no extra authorization is needed here.
  def selected_character_ids
    raw = params[:character_ids]
    values = raw.is_a?(Array) ? raw : raw.to_s.split(",")
    values.filter_map { |value| Integer(value, 10, exception: false) }.uniq
  end

  def slideshow_images_scope(universe_ids)
    scope = Image.where(universe_id: universe_ids)

    scope = scope.joins(:image_favorites).where(image_favorites: { user_id: current_user.id }) if @mode == "favorites"

    character_ids = selected_character_ids
    scope = scope.joins(:appearances).where(appearances: { character_id: character_ids }) if character_ids.any?

    scope.distinct
  end
end
