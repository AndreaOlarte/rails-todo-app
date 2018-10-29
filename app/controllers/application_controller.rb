class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller? #Allows more parameters
  
  # Allows to go to the todos index once user signs in
  def after_sign_in_path_for(resource)
    lists_path
  end

  # Send devise the avatar
  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:avatar, :name, :description])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar, :name, :description])
  end
end
