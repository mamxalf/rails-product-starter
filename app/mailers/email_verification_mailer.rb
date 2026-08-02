class EmailVerificationMailer < ApplicationMailer
  def verification(user)
    @user = user
    @token = Accounts::EmailVerificationToken.generate(user)
    mail_to_user user, subject: t(".subject")
  end
end
