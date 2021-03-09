# frozen_string_literal: true

class UniversesController < ApplicationController
  def index
    owned_universes = Universe.kept.where(owner: current_user)
    collaborated_universes = Universe.kept.joins(:collaborations).where(collaborations: { user: current_user })
    @universes = (owned_universes + collaborated_universes).uniq
  end

  def show
    @universe = Universe.kept.find_by(id: params[:id])
    return unless model_found?(@universe, "Universe", params[:id], universes_url)
    return unless universe_visible_to_user?(@universe)

    @images = Image.where(universe_id: @universe.id).order(created_at: :desc).paginate(page: params[:page],
                                                                                       per_page: 12)
  end

  def new
    @new_universe = Universe.new
  end

  def create
    params = allowed_universe_params.merge(owner_id: current_user.id)
    @universe = Universe.create!(params)
    flash[:success] = "Universe created!"
    redirect_to universes_url
  end

  def edit
    @universe = Universe.kept.find_by(id: params[:id])
    return unless model_found?(@universe, "Universe", params[:id], universes_url)
  end

  def update
    @universe = Universe.kept.find_by(id: params[:id])
    return unless model_found?(@universe, "Universe", params[:id], universes_url)
    return unless universe_visible_to_user?(@universe)

    @universe.update!(allowed_universe_params)
    flash[:success] = "Universe updated!"
    redirect_to universes_url
  end

  private

  def allowed_universe_params
    params.require(:universe).permit(
      :name,
      :owner_id,
      :content,
      :page,
      collaborator_ids: [],
    )
  end
end
