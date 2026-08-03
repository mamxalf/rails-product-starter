module App
  class NotificationsController < BaseController
    def index
      @unread_count = Current.user.notifications.unread.count
      @notifications = Current.user.notifications.recent_first.limit(50)
    end

    def update
      Current.user.notifications.find(params[:id]).update!(read_at: Time.current)
      redirect_to app_notifications_path, notice: "Notification marked as read."
    end

    def read_all
      Current.user.notifications.unread.update_all(read_at: Time.current, updated_at: Time.current)
      redirect_to app_notifications_path, notice: "Notifications marked as read."
    end
  end
end
