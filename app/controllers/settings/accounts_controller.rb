module Settings
  class AccountsController < BaseController
    def show
    end

    def update
      permitted = params.expect(user: %i[email_address current_password])

      password_confirmed = @user.authenticate(permitted[:current_password])

      old_email_address = @user.email_address

      if password_confirmed && @user.update(email_address: permitted[:email_address])
        SecurityMailer.email_changed(@user, old_email_address).deliver_later if old_email_address != @user.email_address
        redirect_to settings_account_path, notice: "Email updated. Check your email to verify your new address."
      else
        @user.errors.add(:base, "Current password is invalid") unless password_confirmed
        render :show, status: :unprocessable_entity
      end
    end

    def destroy
      permitted = params.expect(user: %i[current_password email_confirmation])

      password_confirmed = @user.authenticate(permitted[:current_password])
      email_confirmed = permitted[:email_confirmation] == @user.email_address

      if password_confirmed && email_confirmed
        @user.update!(deactivated_at: Time.current)
        SecurityMailer.account_deactivated(@user).deliver_later
        @user.sessions.destroy_all
        session.delete(:current_session_id)
        cookies.delete(:session_id)
        redirect_to new_session_path, notice: "Account deactivated.", status: :see_other
      else
        @user.errors.add(:base, "Current password is invalid") unless password_confirmed
        @user.errors.add(:base, "Email confirmation must match your email address") unless email_confirmed
        render :show, status: :unprocessable_entity
      end
    end
  end
end
