module VerifiedUserRequired
  extend ActiveSupport::Concern

  included do
    before_action :require_verified_user
  end

  private
    def require_verified_user
      redirect_to new_session_path, alert: "Verify your email address first." unless authenticated? && Current.user.email_verified?
    end
end
