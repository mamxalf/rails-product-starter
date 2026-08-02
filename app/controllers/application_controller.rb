class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private
    def user_not_authorized
      redirect_back_or_to root_path, alert: "You are not authorized to perform this action."
    end
end
