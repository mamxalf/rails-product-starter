module NotSuspended
  extend ActiveSupport::Concern

  included do
    before_action :require_active_account
  end

  private
    def require_active_account
      return unless authenticated?

      if Current.user.suspended? || Current.user.deactivated?
        redirect_to new_session_path, alert: "Your account cannot access the app."
      end
    end
end
