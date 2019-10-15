# frozen_string_literal: true

class ApplicationController < ActionController::API
  def log_error(error, custom_message = "")
    Rails.logger.error "Error in #{controller_name}##{action_name}:"
    Rails.logger.error custom_message unless custom_message.empty?
    Rails.logger.error "Parameters: #{params.inspect}"
    return unless error

    Rails.logger.error error.message
    Rails.logger.error "\t#{error.backtrace.join("\n\t")}"
  end
end
