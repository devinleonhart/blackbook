# frozen_string_literal: true

class API::V1::UniversesController < ApplicationController
  def index
    @universes = Universe.kept
  end

  def show
    @universe = Universe.kept.find_by(id: params[:id])
    return head :not_found if @universe.nil?
  end

  def create
    @universe = Universe.new(allowed_universe_params)
    @universe.save!
  rescue ActiveRecord::RecordInvalid => error
    log_error(
      "Failed model validations during universe#create: #{@universe.errors}",
      params,
      error,
    )
    render json:
      { errors: @universe.errors.full_messages }, status: :bad_request
  rescue ActionController::ParameterMissing => error
    log_error(
      "Missing required parameter to universe#create",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :bad_request
  rescue ActiveRecord::RecordNotFound => error
    log_error(
      "Invalid model ID for an association was provided to universe#create",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :bad_request
  rescue StandardError => error
    log_error(
      "Unexpected error in universe#create",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :internal_server_error
  end

  def update
    @universe = Universe.kept.find_by(id: params[:id])
    return head :not_found if @universe.nil?

    @universe.update!(allowed_universe_params)
  rescue ActiveRecord::RecordInvalid => error
    log_error(
      "Failed model validations during universe#update: #{@universe.errors}",
      params,
      error,
    )
    render(
      json: { errors: @universe.errors.full_messages },
      status: :bad_request,
    )
  rescue ActionController::ParameterMissing => error
    log_error(
      "Missing required parameter to universe#update",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :bad_request
  rescue ActiveRecord::RecordNotFound => error
    log_error(
      "Invalid model ID for an association was provided to universe#update",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :bad_request
  rescue StandardError => error
    log_error(
      "Unexpected error in universe#update",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :internal_server_error
  end

  def destroy
    @universe = Universe.find_by(id: params[:id])
    return head :not_found if @universe.nil?

    @universe.discard! unless @universe.discarded?
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
