require "rails_helper"

RSpec.describe "Settings", type: :request do
  def create_user(**attrs)
    User.create!({
      name: "Member",
      email_address: "member#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      email_verified_at: Time.current
    }.merge(attrs))
  end

  def sign_in(user, password: "password123")
    post session_path, params: { email_address: user.email_address, password: password }
  end

  it "requires login, verification, and an active account" do
    get settings_profile_path
    expect(response).to redirect_to(new_session_path)

    user = create_user(email_verified_at: nil)
    sign_in(user)
    get settings_profile_path
    expect(response).to redirect_to(new_session_path)

    user.update!(email_verified_at: Time.current, suspended_at: Time.current)
    get settings_profile_path
    expect(response).to redirect_to(new_session_path)
  end

  it "renders settings pages for verified active users" do
    user = create_user
    sign_in(user)

    [ settings_profile_path, settings_security_path, settings_preferences_path, settings_sessions_path, settings_account_path ].each do |path|
      get path
      expect(response).to have_http_status(:ok)
    end
  end

  it "updates profile name and rejects invalid profile input" do
    user = create_user
    sign_in(user)

    patch settings_profile_path, params: { user: { name: "Updated" } }

    expect(response).to redirect_to(settings_profile_path)
    expect(user.reload.name).to eq("Updated")

    patch settings_profile_path, params: { user: { name: "" } }
    expect(response).to have_http_status(:unprocessable_content)

    patch settings_profile_path, params: {
      user: {
        name: "Updated",
        avatar: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/avatar.txt"), "text/plain")
      }
    }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "changes password only with the current password" do
    user = create_user
    sign_in(user)

    patch settings_security_path, params: { user: { current_password: "wrong", password: "new-password123", password_confirmation: "new-password123" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(user.reload.authenticate("password123")).to eq(user)

    patch settings_security_path, params: { user: { current_password: "password123", password: "new-password123", password_confirmation: "new-password123" } }
    expect(response).to redirect_to(settings_security_path)
    expect(user.reload.authenticate("new-password123")).to eq(user)
  end

  it "updates valid preferences and rejects invalid values" do
    user = create_user
    sign_in(user)

    patch settings_preferences_path, params: { user: { preferred_locale: "en", time_zone: "UTC" } }
    expect(response).to redirect_to(settings_preferences_path)
    expect(user.reload.attributes.slice("preferred_locale", "time_zone")).to eq("preferred_locale" => "en", "time_zone" => "UTC")

    patch settings_preferences_path, params: { user: { preferred_locale: "fr", time_zone: "Nope/Nowhere" } }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "lists sessions and only revokes other sessions" do
    user = create_user
    other = user.sessions.create!(user_agent: "Other", ip_address: "127.0.0.2")
    sign_in(user)
    current = user.sessions.order(:created_at).last

    get settings_sessions_path
    expect(response.body).to include("Other")

    delete settings_session_path(current)
    expect(response).to redirect_to(settings_sessions_path)
    expect(Session.exists?(current.id)).to be(true)

    delete settings_session_path(other)
    expect(response).to redirect_to(settings_sessions_path)
    expect(Session.exists?(other.id)).to be(false)
  end

  it "changes email with password and sends verification" do
    user = create_user
    sign_in(user)

    expect {
      patch settings_account_path, params: { user: { email_address: "new@example.com", current_password: "password123" } }
    }.to have_enqueued_mail(EmailVerificationMailer, :verification)

    expect(response).to redirect_to(settings_account_path)
    expect(user.reload.email_address).to eq("new@example.com")
    expect(user.email_verified_at).to be_nil
  end

  it "deactivates with password and exact email confirmation" do
    user = create_user
    other_session = user.sessions.create!(user_agent: "Other", ip_address: "127.0.0.2")
    sign_in(user)

    delete settings_account_path, params: { user: { current_password: "wrong", email_confirmation: user.email_address } }
    expect(response).to have_http_status(:unprocessable_content)

    expect {
      delete settings_account_path, params: { user: { current_password: "password123", email_confirmation: user.email_address } }
    }.to have_enqueued_mail(SecurityMailer, :account_deactivated).with(user)

    expect(response).to redirect_to(new_session_path)
    expect(user.reload.deactivated_at).to be_present
    expect(Session.exists?(other_session.id)).to be(false)

    post session_path, params: { email_address: user.email_address, password: "password123" }
    expect(response).to have_http_status(:unprocessable_content)
  end
end
