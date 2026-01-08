# frozen_string_literal: true

class SlideshowsController < ApplicationController
  def show
    universe_ids = accessible_universe_ids_for_user(current_user)
    @mode = slideshow_mode
    @has_images = slideshow_images_scope(universe_ids).limit(1).exists?
  end

  def images
    universe_ids = accessible_universe_ids_for_user(current_user)
    @mode = slideshow_mode

    images =
      slideshow_images_scope(universe_ids)
      .with_attached_image_file
      .limit(5000)
      .to_a
      .shuffle

    slides =
      images.map { |img| { id: img.id, url: view_image_path(img.id, img.image_file.filename.to_s) } }

    render json: { slides: slides }
  end

  private

  def slideshow_mode
    mode = params[:mode].to_s.downcase
    return "favorites" if mode == "favorites"

    "all"
  end

  def slideshow_images_scope(universe_ids)
    case @mode
    when "favorites"
      Image
        .joins(:image_favorites)
        .where(image_favorites: { user_id: current_user.id })
        .where(universe_id: universe_ids)
        .distinct
    else
      Image.where(universe_id: universe_ids)
    end
  end

  # NOTE: duplicated from ImagesController; keep local to avoid refactors unrelated to slideshow.
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
