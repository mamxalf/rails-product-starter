class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  around_action :switch_locale

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private
    def switch_locale(&action)
      I18n.with_locale(current_locale, &action)
    end

    def current_locale
      locale = params[:locale].presence || authenticated_locale || cookies.signed[:locale].presence
      available_locale?(locale) ? locale : I18n.default_locale
    end

    def authenticated_locale
      authenticated? && Current.user&.preferred_locale
    end

    def available_locale?(locale)
      locale.to_s.in?(I18n.available_locales.map(&:to_s))
    end

    def user_not_authorized
      redirect_back_or_to root_path, alert: "You are not authorized to perform this action."
    end
end
