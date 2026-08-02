module StaffAccessRequired
  extend ActiveSupport::Concern

  private
    def require_staff_access
      redirect_to app_path, alert: "You cannot access that page." unless Current.user&.staff? || Current.user&.admin?
    end
end
