class EmailVerificationMailer < ApplicationMailer
  def verification(user)
    @user = user
    @token = Accounts::EmailVerificationToken.generate(user)
    mail_to_user user
  end
end
