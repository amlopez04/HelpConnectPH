class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Include Pundit for authorization
  include Pundit::Authorization

  # Handle authorization failures
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Protect against CSRF attacks
  protect_from_forgery with: :exception

  # Configure Devise parameters
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :barangay_id, :phone_number ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :barangay_id, :phone_number ])
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
