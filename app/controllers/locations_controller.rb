# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action -> { require_universe_visible_to_user("location") },
    only: [:index, :create]

  def index
    @locations = Location.where(universe_id: params[:universe_id])
  end

  def show
    @location = Location.find_by(id: params[:id])
    raise MissingResource.new("location", params[:id]) if @location.nil?

    require_universe_visible_to_user("location", @location.universe.id)
  end

  def create
    properties =
      allowed_location_params.merge(universe_id: params[:universe_id])
    @location = Location.create!(properties)
  end

  def edit
    @location = Location.find_by(id: params[:id])
    raise MissingResource.new("location", params[:id]) if @location.nil?
  end

  def update
    @location = Location.find_by(id: params[:id])
    raise MissingResource.new("location", params[:id]) if @location.nil?

    require_universe_visible_to_user("location", @location.universe.id)

    @location.update!(allowed_location_params)
  end

  def destroy
    @location = Location.find_by(id: params[:id])
    raise MissingResource.new("location", params[:id]) if @location.nil?

    require_universe_visible_to_user("location", @location.universe.id)

    @location.destroy!
    head :no_content
  end

  private

  def allowed_location_params
    params.require(:location).permit(:name, :description)
  end
end
