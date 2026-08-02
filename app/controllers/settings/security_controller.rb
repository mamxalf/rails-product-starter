module Settings
  class SecurityController < BaseController
    def show
    end

    def update
      permitted = params.expect(user: %i[current_password password password_confirmation])

      password_confirmed = @user.authenticate(permitted[:current_password])

      if password_confirmed && @user.update(permitted.except(:current_password))
        SecurityMailer.password_changed(@user).deliver_later
        redirect_to settings_security_path, notice: "Password updated."
      else
        @user.errors.add(:base, "Current password is invalid") unless password_confirmed
        render :show, status: :unprocessable_entity
      end
    end
  end
end
