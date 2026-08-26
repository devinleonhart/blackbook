# frozen_string_literal: true

class SlideshowsController < ApplicationController
  def show
    universe_ids = Universe.accessible_to(current_user).pluck(:id)
    @mode = slideshow_mode
    @universe_id = selected_universe_id!(universe_ids)
    @trait_names = selected_trait_names
    @character_ids = selected_character_ids
    @universes = Universe.where(id: universe_ids).order(Arel.sql("LOWER(universes.name) ASC"))

    @available_trait_names = @universe_id ? universe_trait_names(@universe_id) : []
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

  def selected_trait_names
    raw = params[:trait_names]
    values = raw.is_a?(Array) ? raw : raw.to_s.split(",")
    values.map { |value| value.to_s.strip.downcase }.compact_blank.uniq
  end

  def selected_character_ids
    raw = params[:character_ids]
    values = raw.is_a?(Array) ? raw : raw.to_s.split(",")
    values.filter_map { |value| Integer(value, 10, exception: false) }.uniq
  end

  def universe_trait_names(universe_id)
    Trait.joins(:character)
         .where(characters: { universe_id: universe_id })
         .distinct
         .order(:name)
         .pluck(:name)
  end

  def slideshow_images_scope(universe_ids)
    scope = Image.where(universe_id: universe_ids)

    scope = scope.joins(:image_favorites).where(image_favorites: { user_id: current_user.id }) if @mode == "favorites"

    character_ids = filter_character_ids(universe_ids)
    scope = scope.joins(:appearances).where(appearances: { character_id: character_ids }) unless character_ids.nil?

    scope.distinct
  end

  # nil when no filter is active; otherwise chosen characters plus every
  # character carrying a chosen trait ([] matches no images).
  def filter_character_ids(universe_ids)
    trait_names = selected_trait_names
    character_ids = selected_character_ids
    return nil if trait_names.empty? && character_ids.empty?

    trait_character_ids =
      if trait_names.any?
        Character.joins(:traits).where(universe_id: universe_ids, traits: { name: trait_names }).pluck(:id)
      else
        []
      end

    (character_ids + trait_character_ids).uniq
  end
end
