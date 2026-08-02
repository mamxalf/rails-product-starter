class SecurityMailer < ApplicationMailer
  def account_deactivated(user)
    @user = user
    mail_to_user user, subject: t(".subject")
  end
end
