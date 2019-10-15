# frozen_string_literal: true

class API::V1::ApplicationController < ::ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_api_v1_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActionController::ParameterMissing,
    with: :handle_parameter_missing
  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
  rescue_from ActiveRecord::RecordNotFound,
    with: :handle_associated_record_not_found

  rescue_from BlackBookError, with: :handle_black_book_error

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  end

  def handle_parameter_missing(error)
    log_error(error)
    render json: { errors: [error.message] }, status: :bad_request
  end

  def handle_record_invalid(error)
    log_error(error, error.record.errors.full_messages.join(", "))
    render json:
      { errors: error.record.errors.full_messages }, status: :bad_request
  end

  def handle_associated_record_not_found(error)
    log_error(error)
    render(
      json: { errors: ["No #{error.model} with ID #{error.id} exists."] },
      status: :bad_request,
    )
  end

  def handle_forbidden_universe_action(error)
    log_error(error)
    render json: { errors: [error.message] }, status: :forbidden
  end

  def handle_forbidden_universe_resource(error)
    log_error(error)
    render json: { errors: [error.message] }, status: :forbidden
  end

  def handle_black_book_error(error)
    log_error(error)
    render json: { errors: [error.message] }, status: error.status
  end

  private

  def require_universe_visible_to_user(model_name)
    universe = Universe.kept.find_by(id: params[:universe_id])
    raise MissingResource.new("universe", params[:universe_id]) if universe.nil?

    unless universe.visible_to_user?(current_api_v1_user)
      raise ForbiddenUniverseResource.new(universe.id, model_name)
    end
  end
end
