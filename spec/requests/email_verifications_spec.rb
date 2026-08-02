require "rails_helper"

RSpec.describe "Email verifications", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  it "verifies an account once and remains idempotent" do
    user = User.create!(name: "Member", email_address: "member@example.com", password: "password123")
    token = Accounts::EmailVerificationToken.generate(user)

    get verify_email_path(token)
    first_verified_at = user.reload.email_verified_at
    get verify_email_path(token)

    expect(first_verified_at).to be_present
    expect(user.reload.email_verified_at.to_i).to eq(first_verified_at.to_i)
    expect(response).to redirect_to(app_dashboard_path)
  end

  it "rejects invalid, expired, and wrong-purpose tokens safely" do
    user = User.create!(name: "Member", email_address: "member@example.com", password: "password123")
    wrong_purpose = user.signed_id(purpose: :password_reset, expires_in: 24.hours)

    get verify_email_path("bad-token")
    expect(response).to redirect_to(new_session_path)

    get verify_email_path(wrong_purpose)
    expect(response).to redirect_to(new_session_path)

    token = Accounts::EmailVerificationToken.generate(user)
    travel 25.hours do
      get verify_email_path(token)
    end
    expect(response).to redirect_to(new_session_path)
    expect(user.reload.email_verified_at).to be_nil
  end

  it "resends verification with rate limiting" do
    user = User.create!(name: "Member", email_address: "member@example.com", password: "password123")
    post session_path, params: { email_address: user.email_address, password: "password123" }

    expect {
      post email_verification_path
    }.to have_enqueued_mail(EmailVerificationMailer, :verification).with(user)

    post email_verification_path

    expect(response).to have_http_status(:too_many_requests)
  end

  it "blocks unverified and suspended users from the app" do
    user = User.create!(name: "Member", email_address: "member@example.com", password: "password123")
    post session_path, params: { email_address: user.email_address, password: "password123" }

    get app_dashboard_path
    expect(response).to redirect_to(new_session_path)

    user.update!(email_verified_at: Time.current, suspended_at: Time.current)
    get app_dashboard_path
    expect(response).to redirect_to(new_session_path)
  end

  it "allows verified active users into the app" do
    user = User.create!(name: "Member", email_address: "member@example.com", password: "password123", email_verified_at: Time.current)
    post session_path, params: { email_address: user.email_address, password: "password123" }

    get app_dashboard_path

    expect(response).to have_http_status(:ok)
  end
end
