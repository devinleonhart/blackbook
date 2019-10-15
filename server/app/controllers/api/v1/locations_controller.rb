# frozen_string_literal: true

class API::V1::LocationsController < API::V1::ApplicationController
  before_action -> { require_universe_visible_to_user("location") },
    only: [:index, :create]

  def index
    @locations = Location.where(universe_id: params[:universe_id]).all
  end

  def show
    @location = Location.find_by(id: params[:id])
    raise MissingResource.new("location", params[:id]) if @location.nil?
    unless @location.universe.visible_to_user?(current_api_v1_user)
      raise ForbiddenUniverseResource.new(@location.universe.id, "location")
    end
  end

  def create
    properties =
      allowed_location_params.merge(universe_id: params[:universe_id])
    @location = Location.new(properties)
    @location.save!
  end

  def update
    @location = Location.find_by(id: params[:id])
    raise MissingResource.new("location", params[:id]) if @location.nil?
    unless @location.universe.visible_to_user?(current_api_v1_user)
      raise ForbiddenUniverseResource.new(@location.universe.id, "location")
    end

    if allowed_location_params[:universe_id]
      new_universe = Universe.find_by(id: allowed_location_params[:universe_id])
      if new_universe && !new_universe.visible_to_user?(current_api_v1_user)
        raise ForbiddenUniverseResourceReassignment.new(
          new_universe.id, "location",
        )
      end
    end

    @location.update!(allowed_location_params)
  end

  def destroy
    @location = Location.find_by(id: params[:id])
    raise MissingResource.new("location", params[:id]) if @location.nil?
    unless @location.universe.visible_to_user?(current_api_v1_user)
      raise ForbiddenUniverseResource.new(@location.universe.id, "location")
    end

    @location.destroy!
    head :no_content
  end

  private

  def allowed_location_params
    params.require(:location).permit(
      :name,
      :description,
      :universe_id,
    )
  end
end
