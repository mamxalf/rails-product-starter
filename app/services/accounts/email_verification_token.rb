module Accounts
  class EmailVerificationToken
    PURPOSE = :email_verification
    EXPIRES_IN = 24.hours

    def self.generate(user)
      user.signed_id(purpose: PURPOSE, expires_in: EXPIRES_IN)
    end

    def self.find(token)
      User.find_signed(token, purpose: PURPOSE)
    end
  end
end
