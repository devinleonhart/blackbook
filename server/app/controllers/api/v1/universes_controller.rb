# frozen_string_literal: true

class API::V1::UniversesController < API::V1::ApplicationController
  def index
    owned_universes =
      Universe.kept.where(owner: current_api_v1_user).all

    collaborated_universes =
      Universe
      .kept
      .joins(:collaborations)
      .where(collaborations: { user: current_api_v1_user })
      .all

    @universes = (owned_universes + collaborated_universes).uniq
  end

  def show
    @universe = Universe.kept.find_by(id: params[:id])
    raise MissingResource.new("universe", params[:id]) if @universe.nil?
    unless @universe.visible_to_user?(current_api_v1_user)
      raise ForbiddenUniverseAction.new("viewed", true)
    end
  end

  def create
    @universe = Universe.create!(allowed_universe_params)
  end

  def update
    @universe = Universe.kept.find_by(id: params[:id])
    raise MissingResource.new("universe", params[:id]) if @universe.nil?

    if @universe.owner != current_api_v1_user
      raise ForbiddenUniverseAction.new("changed", false)
    end

    @universe.update!(allowed_universe_params)
  end

  def destroy
    @universe = Universe.kept.find_by(id: params[:id])
    raise MissingResource.new("universe", params[:id]) if @universe.nil?

    if @universe.owner != current_api_v1_user
      raise ForbiddenUniverseAction.new("deleted", false)
    end

    @universe.discard!
    head :no_content
  end

  private

  def allowed_universe_params
    params.require(:universe).permit(
      :name,
      :owner_id,
      collaborator_ids: [],
    )
  end
end
