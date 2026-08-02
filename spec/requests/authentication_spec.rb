require "rails_helper"

RSpec.describe "Authentication", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  it "logs in with valid credentials" do
    user = User.create!(name: "Member", email_address: "member@example.com", password: "password123", email_verified_at: Time.current)

    post session_path, params: { email_address: user.email_address, password: "password123" }

    expect(response).to redirect_to(app_dashboard_path)
    follow_redirect!
    expect(response.body).to include("Dashboard")
  end

  it "rejects invalid credentials" do
    User.create!(name: "Member", email_address: "member@example.com", password: "password123")

    post session_path, params: { email_address: "member@example.com", password: "wrong" }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Try another email address or password")
  end

  it "logs out of the current session" do
    user = User.create!(name: "Member", email_address: "member@example.com", password: "password123", email_verified_at: Time.current)
    post session_path, params: { email_address: user.email_address, password: "password123" }

    delete session_path
    get app_dashboard_path

    expect(response).to redirect_to(new_session_path)
  end

  it "sends a password reset message" do
    user = User.create!(name: "Member", email_address: "member@example.com", password: "password123")

    expect {
      post passwords_path, params: { email_address: user.email_address }
    }.to have_enqueued_mail(PasswordsMailer, :reset).with(user)
  end

  it "resets a password once with a valid token" do
    user = User.create!(name: "Member", email_address: "member@example.com", password: "password123")
    token = user.password_reset_token

    put password_path(token), params: { password: "new-password123", password_confirmation: "new-password123" }

    expect(response).to redirect_to(new_session_path)
    expect(user.reload.authenticate("new-password123")).to eq(user)
    expect(User.find_by_password_reset_token(token)).to be_nil
  end

  it "rejects expired password reset tokens safely" do
    user = User.create!(name: "Member", email_address: "member@example.com", password: "password123")
    token = user.password_reset_token

    travel 16.minutes do
      put password_path(token), params: { password: "new-password123", password_confirmation: "new-password123" }
    end

    expect(response).to redirect_to(new_password_path)
    expect(user.reload.authenticate("password123")).to eq(user)
  end
end
