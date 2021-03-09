# frozen_string_literal: true

class LocationsController < ApplicationController
  def index
    @locations = Location.where(universe_id: params[:universe_id])
  end

  def show
    @location = Location.find_by(id: params[:id])
    return unless model_found?(@location, "Location", params[:id], universes_url)
    return unless universe_visible_to_user?(@location.universe)
  end

  def new
    @new_location = Location.new(universe_id: params[:universe_id])
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
    return unless model_found?(@location, "Location", params[:id], universes_url)
  end

  def update
    @location = Location.find_by(id: params[:id])
    return unless model_found?(@location, "Location", params[:id], universes_url)
    return unless universe_visible_to_user?(@location.universe)

    flash[:success] = "Location updated!"
    @location.update!(allowed_location_params)
    redirect_to location_url(@location)
  end

  def destroy
    @location = Location.find_by(id: params[:id])
    return unless model_found?(@location, "Location", params[:id], universes_url)
    return unless universe_visible_to_user?(@location.universe)

    @location.destroy!
    flash[:success] = "Location deleted!"
    redirect_to universe_url(@location.universe)
  end

  private

  def allowed_location_params
    params.require(:location).permit(:name, :content)
  end
end
