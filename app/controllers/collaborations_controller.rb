# frozen_string_literal: true

class CollaborationsController < ApplicationController
  def show
    @collaboration = Collaboration.includes(:user, :universe).find_by(id: params[:id])
    return unless model_found?(@collaboration, "Collaboration", params[:id], universes_url)
  end

  def create
    properties = allowed_collaboration_params.merge(universe_id: params[:universe_id])
    universe = Universe.find_by(id: params[:universe_id])
    return unless model_found?(universe, "Universe", params[:universe_id], universes_url)
    @collaboration = Collaboration.create!(properties)
    redirect_to edit_universe_url(params[:universe_id])
  end

  def destroy
    @collaboration = Collaboration.find_by(id: params[:id])
    return unless model_found?(@collaboration, "Collaboration", params[:id], universes_url)
    @collaboration.destroy!
    redirect_to edit_universe_url(@collaboration.universe.id)
  end

  private

  def allowed_collaboration_params
    params.require(:collaboration).permit(:universe_id, :user_id)
  end
end
