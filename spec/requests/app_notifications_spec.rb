require "rails_helper"

RSpec.describe "App notifications", type: :request do
  def create_user(**attrs)
    User.create!({
      name: "Member",
      email_address: "member#{SecureRandom.hex(4)}@example.test",
      password: "password123",
      email_verified_at: Time.current
    }.merge(attrs))
  end

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password123" }
  end

  it "requires login, verification, and an active account" do
    get app_notifications_path
    expect(response).to redirect_to(new_session_path)

    user = create_user(email_verified_at: nil)
    sign_in(user)
    get app_notifications_path
    expect(response).to redirect_to(new_session_path)

    user.update!(email_verified_at: Time.current, suspended_at: Time.current)
    get app_notifications_path
    expect(response).to redirect_to(new_session_path)
  end

  it "lists and marks the current user's notifications read" do
    user = create_user
    own = Notification.create!(user:, kind: "system", title: "Welcome", body: "Body", action_url: "/app/dashboard")
    other = Notification.create!(user: create_user, kind: "system", title: "Other", body: "Body")
    sign_in(user)

    get app_notifications_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Notifications")
    expect(response.body).to include("1 unread")
    expect(response.body).to include(read_all_app_notifications_path)
    expect(response.body).to include(app_notification_path(own))
    expect(response.body).to include("Welcome")
    expect(response.body).not_to include("Other")
    expect(response.body).not_to include("inertia")

    patch app_notification_path(own)
    expect(response).to redirect_to(app_notifications_path)
    expect(own.reload.read_at).to be_present

    patch app_notification_path(other)
    expect(response).to have_http_status(:not_found)

    own.update!(read_at: nil)
    patch read_all_app_notifications_path
    expect(response).to redirect_to(app_notifications_path)
    expect(own.reload.read_at).to be_present
  end
end
