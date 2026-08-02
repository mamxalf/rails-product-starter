class SecurityMailer < ApplicationMailer
  def account_deactivated(user)
    @user = user
    mail_to_user user
  end

  def password_changed(user)
    @user = user
    mail_to_user user
  end

  def email_changed(user, old_email_address)
    @user = user
    mail_to_user user, to: old_email_address
  end
end
