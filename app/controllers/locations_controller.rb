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
    @location = Location.new(properties)

    if @location.save
      flash[:success] = "Location created!"
      redirect_to location_url(@location)
    else
      flash[:error] = @location.errors.full_messages.join("\n")
      redirect_to new_universe_location_url(params[:universe_id])
    end
  end

  def edit
    @location = Location.find_by(id: params[:id])
    return unless model_found?(@location, "Location", params[:id], universes_url)
  end

  def update
    @location = Location.find_by(id: params[:id])
    return unless model_found?(@location, "Location", params[:id], universes_url)
    return unless universe_visible_to_user?(@location.universe)

    @location.update(allowed_location_params)

    if @location.save
      flash[:success] = "Location updated!"
      redirect_to location_url(@location)
    else
      flash[:error] = @location.errors.full_messages.join("\n")
      redirect_to edit_location_url(params[:id])
    end
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
