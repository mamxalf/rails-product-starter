module Settings
  class SessionsController < BaseController
    def index
      @sessions = @user.sessions.order(created_at: :desc)
    end

    def destroy
      session = @user.sessions.find(params[:id])
      session.destroy unless session == Current.session

      redirect_to settings_sessions_path, notice: "Session updated.", status: :see_other
    end
  end
end
