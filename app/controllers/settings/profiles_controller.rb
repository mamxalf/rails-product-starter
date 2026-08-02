module Settings
  class ProfilesController < BaseController
    def show
    end

    def update
      if @user.update(profile_params)
        redirect_to settings_profile_path, notice: "Profile updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private
      def profile_params
        params.expect(user: %i[name avatar])
      end
  end
end
