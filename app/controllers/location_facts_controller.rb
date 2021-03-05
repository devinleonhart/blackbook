# frozen_string_literal: true

class LocationFactsController < ApplicationController
  def create
    properties =
      allowed_location_fact_params.merge(location_id: params[:location_id])
    @fact = Fact.create!(properties)
    redirect_to location_url(@fact.location)
  end

  def destroy
    @fact = Fact.find_by(id: params[:id])
    raise MissingResource.new("fact", params[:id]) if @fact.nil?

    require_universe_visible_to_user("fact", @fact.location.universe.id)

    @fact.destroy!
    redirect_to location_url(@fact.location)
  end

  private

  def allowed_location_fact_params
    params.require(:fact).permit(:fact_type, :content)
  end
end
