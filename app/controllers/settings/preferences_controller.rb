module Settings
  class PreferencesController < BaseController
    def show
    end

    def update
      if @user.update(preferences_params)
        redirect_to settings_preferences_path, notice: "Preferences updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private
      def preferences_params
        params.expect(user: %i[preferred_locale time_zone])
      end
  end
end
