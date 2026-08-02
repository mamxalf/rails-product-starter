module Admin
  class NotificationsController < BaseController
    AUDIENCES = %w[all_active members staff].freeze

    before_action :require_admin, only: :create

    def index
      @audit_events = AuditEvent.includes(:actor).where(action: "admin.notifications.announcement").order(created_at: :desc).limit(20)
    end

    def new
      @announcement = {}
    end

    def create
      permitted = params.expect(announcement: %i[title body action_url audience])
      @announcement = permitted.to_h

      unless AUDIENCES.include?(@announcement["audience"])
        flash.now[:alert] = "Audience is invalid."
        return render :new, status: :unprocessable_entity
      end

      notification = Notification.new(
        user: Current.user,
        kind: "admin_announcement",
        title: @announcement["title"],
        body: @announcement["body"],
        action_url: @announcement["action_url"]
      )
      unless notification.valid?
        flash.now[:alert] = notification.errors.full_messages.to_sentence
        return render :new, status: :unprocessable_entity
      end

      announcement_id = SecureRandom.uuid
      Notifications::FanOutAnnouncementJob.perform_later(
        actor_id: Current.user.id,
        audience: @announcement["audience"],
        title: @announcement["title"],
        body: @announcement["body"],
        action_url: @announcement["action_url"],
        announcement_id: announcement_id
      )
      Auditing::Record.call(
        action: "admin.notifications.announcement",
        actor: Current.user,
        target: Current.user,
        metadata: @announcement.merge("announcement_id" => announcement_id),
        request: request
      )

      redirect_to admin_notifications_path, notice: "Announcement queued."
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_entity
    end

    private
      def require_admin
        authorize Current.user, :manage_staff?
      end
  end
end
