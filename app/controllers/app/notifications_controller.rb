module App
  class NotificationsController < BaseController
    def index
      render inertia: "app/Notifications", props: {
        notifications: {
          unread_count: Current.user.notifications.unread.count,
          items: Current.user.notifications.recent_first.limit(50).map { |notification| serialize(notification) }
        }
      }
    end

    def update
      Current.user.notifications.find(params[:id]).update!(read_at: Time.current)
      redirect_to app_notifications_path, notice: "Notification marked as read."
    end

    def read_all
      Current.user.notifications.unread.update_all(read_at: Time.current, updated_at: Time.current)
      redirect_to app_notifications_path, notice: "Notifications marked as read."
    end

    private
      def serialize(notification)
        {
          id: notification.id,
          kind: notification.kind,
          title: notification.title,
          body: notification.body,
          action_url: notification.action_url,
          read_at: notification.read_at&.iso8601,
          created_at: notification.created_at.iso8601
        }
      end
  end
end
