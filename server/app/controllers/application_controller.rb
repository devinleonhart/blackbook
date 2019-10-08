# frozen_string_literal: true

class ApplicationController < ActionController::API
  def log_error(message, params, error)
    Rails.logger.error message
    Rails.logger.error "Parameters: #{params.inspect}"
    return unless error

    Rails.logger.error error.message
    Rails.logger.error "\t#{error.backtrace.join("\n\t")}"
  end
end
