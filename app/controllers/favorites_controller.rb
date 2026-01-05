# frozen_string_literal: true

class FavoritesController < ApplicationController
  def index
    favorites =
      Image
      .joins(:image_favorites)
      .includes(:universe)
      .where(image_favorites: { user_id: current_user.id })
      .order("universes.name ASC", created_at: :desc)

    @favorites_by_universe = favorites.group_by(&:universe)
    @universes = @favorites_by_universe.keys.sort_by { |u| u.name.to_s.downcase }
  end
end
