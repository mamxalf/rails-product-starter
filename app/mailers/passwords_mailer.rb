class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail_to_user user, subject: t(".subject")
  end
end
