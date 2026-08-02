module Admin
  class UsersController < BaseController
    include Pagy::Method

    before_action :set_user, only: %i[show role suspend unsuspend revoke_sessions]

    def index
      @query = UsersQuery.new(**query_params)
      @pagy, @users = pagy(:offset, @query.relation, limit: 25)
    end

    def show
      @active_sessions_count = @user.sessions.count
      @audit_events = @user.audit_events.includes(:actor).order(created_at: :desc).limit(10)
    end

    def role
      Users::ChangeRole.call(actor: Current.user, target: @user, role: params.dig(:user, :role), request: request)
      redirect_to admin_user_path(@user), notice: "User role updated."
    rescue Users::Error => error
      redirect_to admin_user_path(@user), alert: error.message
    end

    def suspend
      Users::Suspend.call(actor: Current.user, target: @user, request: request)
      redirect_to admin_user_path(@user), notice: "User suspended."
    rescue Users::Error => error
      redirect_to admin_user_path(@user), alert: error.message
    end

    def unsuspend
      Users::Unsuspend.call(actor: Current.user, target: @user, request: request)
      redirect_to admin_user_path(@user), notice: "User unsuspended."
    rescue Users::Error => error
      redirect_to admin_user_path(@user), alert: error.message
    end

    def revoke_sessions
      Users::RevokeSessions.call(actor: Current.user, target: @user, request: request)
      redirect_to admin_user_path(@user), notice: "User sessions revoked."
    rescue Users::Error => error
      redirect_to admin_user_path(@user), alert: error.message
    end

    private
      def set_user
        @user = User.find(params[:id])
      end

      def query_params
        params.permit(:search, :role, :verification, :status, :sort).to_h.symbolize_keys
      end
  end
end
