# frozen_string_literal: true

class UniversesController < ApplicationController
  def index

    owned_universes =
      Universe.kept.where(owner: current_user)

    collaborated_universes =
      Universe
      .kept
      .joins(:collaborations)
      .where(collaborations: { user: current_user })

    @universes = (owned_universes + collaborated_universes).uniq

  end

  def show
    @universe = Universe.kept.find_by(id: params[:id])
    raise MissingResource.new("universe", params[:id]) if @universe.nil?
    unless @universe.visible_to_user?(current_user)
      raise ForbiddenUniverseAction.new("viewed", true)
    end
  end

  def create
    @universe = Universe.create!(allowed_universe_params)
    flash[:success] = "Universe created!"
    redirect_to universes_url()
  end

  def edit
    @universe = Universe.kept.find_by(id: params[:id])
    raise MissingResource.new("universe", params[:id]) if @universe.nil?
  end

  def update
    @universe = Universe.kept.find_by(id: params[:id])
    raise MissingResource.new("universe", params[:id]) if @universe.nil?

    if @universe.owner != current_user
      flash[:alert] = "You are not the owner of this universe."
      raise ForbiddenUniverseAction.new("changed", false)
    end

    @universe.update!(allowed_universe_params)
    flash[:success] = "Universe updated!"
    redirect_to universes_url()
  end

  def destroy
    @universe = Universe.kept.find_by(id: params[:id])
    raise MissingResource.new("universe", params[:id]) if @universe.nil?

    if @universe.owner != current_user
      raise ForbiddenUniverseAction.new("deleted", false)
    end

    @universe.discard!
    flash[:success] = "Universe deleted!"
    redirect_to universes_url()
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
