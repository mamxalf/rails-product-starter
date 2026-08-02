class EmailVerificationsController < ApplicationController
  allow_unauthenticated_access only: :show
  rate_limit to: 1, within: 1.minute, only: :create, with: -> { head :too_many_requests }

  def show
    if user = Accounts::EmailVerificationToken.find(params[:token])
      user.update!(email_verified_at: Time.current) unless user.email_verified?
      start_new_session_for(user) unless Current.user == user
      redirect_to app_dashboard_path, notice: "Email address verified."
    else
      redirect_to new_session_path, alert: "Email verification link is invalid or expired."
    end
  end

  def create
    return head :too_many_requests if recently_sent?

    EmailVerificationMailer.verification(Current.user).deliver_later unless Current.user.email_verified?
    session[:email_verification_sent_at] = Time.current.to_i
    redirect_to app_dashboard_path, notice: "Verification email sent."
  end

  private
    def recently_sent?
      session[:email_verification_sent_at].to_i > 1.minute.ago.to_i
    end
end
