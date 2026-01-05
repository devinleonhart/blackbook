class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :display_name])
  end

  def error_and_redirect(message, path)
    flash[:error] = message
    redirect_to path
  end

  def model_found?(model, name, id, path)
    if model.nil?
      error_and_redirect("No #{name} was found with ID: #{id}", path)
      return false
    end
    true
  end

  def universe_visible_to_user?(universe)
    unless universe.visible_to_user?(current_user)
      error_and_redirect("You are not an owner or collaborator of this universe.",
        universes_url)
      return false
    end
    true
  end

end
