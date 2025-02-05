# frozen_string_literal: true

class UniversesController < ApplicationController
  def index
    owned_universes = Universe.where(owner: current_user)
    collaborated_universes = Universe.joins(:collaborations).where(collaborations: { user: current_user })
    @universes = (owned_universes + collaborated_universes).uniq
  end

  def show
    @universe = Universe.find_by(id: params[:id])
    return unless model_found?(@universe, "Universe", params[:id], universes_url)
    return unless universe_visible_to_user?(@universe)

    @images = Image.where(universe_id: @universe.id).order(created_at: :desc).paginate(page: params[:page], per_page: 20)
  end

  def new
    @new_universe = Universe.new
  end

  def create
    params = allowed_universe_params.merge(owner_id: current_user.id)
    @universe = Universe.new(params)
    if @universe.save
      flash[:success] = "Universe created!"
      redirect_to universes_url
    else
      flash[:error] = @universe.errors.full_messages.join("\n")
      redirect_to new_universe_url
    end
  end

  def edit
    @universe = Universe.find_by(id: params[:id])
    return unless model_found?(@universe, "Universe", params[:id], universes_url)
  end

  def update
    @universe = Universe.find_by(id: params[:id])
    return unless model_found?(@universe, "Universe", params[:id], universes_url)
    return unless universe_visible_to_user?(@universe)

    if @universe.update(allowed_universe_params)
      flash[:success] = "Universe updated!"
      redirect_to universes_url
    else
      flash[:error] = @universe.errors.full_messages.join("\n")
      redirect_to edit_universe_url(@universe)
    end
  end

  private

  def allowed_universe_params
    params.require(:universe).permit(
      :name,
      :owner_id,
      :page,
      collaborator_ids: [],
    )
  end
end
