# frozen_string_literal: true

class CollaborationsController < ApplicationController
  before_action :set_universe_and_authorize_owner

  def create
    @collaboration = @universe.collaborations.new(allowed_collaboration_params)

    flash[:error] = @collaboration.errors.full_messages.join("\n") unless @collaboration.save
    redirect_to edit_universe_url(@universe)
  end

  def destroy
    @collaboration.destroy!
    redirect_to edit_universe_url(@universe)
  end

  private

  # Managing collaborators is an OWNER-only action (stronger than merely being
  # able to view the universe). create is nested (universe_id in the path);
  # destroy is shallow (only the collaboration id), so derive the universe from
  # the collaboration in that case.
  def set_universe_and_authorize_owner
    @collaboration = Collaboration.find_by(id: params[:id]) if params[:id]
    @universe = params[:universe_id] ? Universe.find_by(id: params[:universe_id]) : @collaboration&.universe

    return unless required_record_found?
    return if @universe.owner_id == current_user.id

    error_and_redirect("You must be the owner of this universe to manage collaborators.", universes_url)
  end

  # create is nested (universe_id present, universe must exist); destroy is
  # shallow (only the collaboration id, which must resolve to a universe).
  def required_record_found?
    if params[:universe_id]
      model_found?(@universe, "Universe", params[:universe_id], universes_url)
    else
      model_found?(@collaboration, "Collaboration", params[:id], universes_url)
    end
  end

  def allowed_collaboration_params
    params.expect(collaboration: [:user_id])
  end
end
