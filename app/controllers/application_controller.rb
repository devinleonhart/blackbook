# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  rescue_from ActionController::ParameterMissing,
    with: :handle_parameter_missing
  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
  rescue_from ActiveRecord::RecordNotFound,
    with: :handle_associated_record_not_found

  rescue_from BlackBookError, with: :handle_blackbook_error

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :display_name])
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

  def handle_blackbook_error(error)
    log_error(error)
    render json: { errors: [error.message] }, status: error.status
  end

  private

  def require_universe_visible_to_user(
    model_name,
    universe_id = params[:universe_id]
  )
    universe = Universe.kept.find_by(id: universe_id)
    raise MissingResource.new("universe", universe_id) if universe.nil?

    raise ForbiddenUniverseResource.new(universe.id, model_name) unless universe.visible_to_user?(current_user)
  end

  def require_resource_be_in_universe(
    resource_class,
    resource_id,
    universe_id
  )
    resource = resource_class.find_by(id: resource_id)
    return if resource.nil?

    if resource.universe.id != universe_id.to_i
      raise ResourceNotInUniverse.new(
        resource_class.name,
        resource_id,
        universe_id,
      )
    end
  end

  def log_error(error, custom_message = "")
    Rails.logger.error "Error in #{controller_name}##{action_name}:"
    Rails.logger.error custom_message unless custom_message.empty?
    Rails.logger.error "Parameters: #{params.inspect}"
    return unless error

    Rails.logger.error error.message
    Rails.logger.error "\t#{error.backtrace.join("\n\t")}"
  end
end
