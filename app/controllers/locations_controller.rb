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

  def new
    @location = Location.new(universe_id: params[:universe_id])
  end

  def create
    properties =
      allowed_location_params.merge(universe_id: params[:universe_id])
    @location = Location.create!(properties)
    flash[:success] = "Location created!"
    redirect_to location_url(@location)
  end

  def edit
    @location = Location.find_by(id: params[:id])
    raise MissingResource.new("location", params[:id]) if @location.nil?
  end

  def update
    @location = Location.find_by(id: params[:id])
    raise MissingResource.new("location", params[:id]) if @location.nil?

    require_universe_visible_to_user("location", @location.universe.id)

    flash[:success] = "Location updated!"
    @location.update!(allowed_location_params)
    redirect_to location_url(@location)
  end

  def destroy
    @location = Location.find_by(id: params[:id])
    raise MissingResource.new("location", params[:id]) if @location.nil?

    require_universe_visible_to_user("location", @location.universe.id)

    @location.destroy!
    flash[:success] = "Location deleted!"
    redirect_to universe_url(@location.universe)
  end

  private

  def allowed_location_params
    params.require(:location).permit(:name, :content)
  end
end
