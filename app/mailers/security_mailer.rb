class SecurityMailer < ApplicationMailer
  def account_deactivated(user)
    @user = user
    mail subject: "Your account was deactivated", to: user.email_address
  end
end
