# frozen_string_literal: true

class CollaborationsController < ApplicationController
  def show
    @collaboration =
      Collaboration
      .includes(:user, :universe)
      .find_by(id: params[:id])

    raise MissingResource.new("collaboration", params[:id]) if @collaboration.nil?
  end

  def create
    properties =
      allowed_collaboration_params.merge(universe_id: params[:universe_id])

    universe = Universe.find_by(id: params[:universe_id])
    raise MissingResource.new("universe", params[:universe_id]) if universe.nil?

    @collaboration = Collaboration.create! properties
    redirect_to edit_universe_url(params[:universe_id])
  end

  def destroy
    @collaboration = Collaboration.find_by(id: params[:id])
    raise MissingResource.new("collaboration", params[:id]) if @collaboration.nil?

    @collaboration.destroy!
    redirect_to edit_universe_url(@collaboration.universe.id)
  end

  private

  def allowed_collaboration_params
    params.require(:collaboration).permit(:universe_id, :user_id)
  end
end
