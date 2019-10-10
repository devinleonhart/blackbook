# frozen_string_literal: true

class API::V1::LocationsController < ApplicationController
  def index
    if params[:universe_id].blank?
      raise "Missing required parameter \"universe_id\""
    end

    @locations = Location.where(universe_id: params[:universe_id]).all
  rescue ActionController::ParameterMissing => error
    log_error(
      "Missing required parameter to location#index",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :bad_request
  end

  def show
    @location = Location.find_by(id: params[:id])
    return head :not_found if @location.nil?
  end

  def create
    properties =
      allowed_location_params.merge(universe_id: params[:universe_id])
    @location = Location.new(properties)
    @location.save!
  rescue ActiveRecord::RecordInvalid => error
    log_error(
      "Failed model validations during location#create: #{@location.errors}",
      params,
      error,
    )
    render json:
      { errors: @location.errors.full_messages }, status: :bad_request
  rescue ActionController::ParameterMissing => error
    log_error(
      "Missing required parameter to location#create",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :bad_request
  rescue ActiveRecord::RecordNotFound => error
    log_error(
      "Invalid model ID for an association was provided to location#create",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :bad_request
  rescue StandardError => error
    log_error(
      "Unexpected error in location#create",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :internal_server_error
  end

  def update
    @location = Location.find_by(id: params[:id])
    return head :not_found if @location.nil?

    @location.update!(allowed_location_params)
  rescue ActiveRecord::RecordInvalid => error
    log_error(
      "Failed model validations during location#update: #{@location.errors}",
      params,
      error,
    )
    render(
      json: { errors: @location.errors.full_messages },
      status: :bad_request,
    )
  rescue ActionController::ParameterMissing => error
    log_error(
      "Missing required parameter to location#update",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :bad_request
  rescue ActiveRecord::RecordNotFound => error
    log_error(
      "Invalid model ID for an association was provided to location#update",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :bad_request
  rescue StandardError => error
    log_error(
      "Unexpected error in location#update",
      params,
      error,
    )
    render json: { errors: [error.message] }, status: :internal_server_error
  end

  def destroy
    @location = Location.find_by(id: params[:id])
    return head :not_found if @location.nil?

    @location.destroy!
    head :no_content
  end

  private

  def allowed_location_params
    params.require(:location).permit(
      :name,
      :description,
      :universe_id,
    )
  end
end
