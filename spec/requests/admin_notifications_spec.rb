require "rails_helper"

RSpec.describe "Admin notifications", type: :request do
  def create_user(role: :member, **attrs)
    User.create!({
      name: role.to_s.titleize,
      email_address: "#{role}-#{SecureRandom.hex(4)}@example.test",
      password: "password123",
      role: role,
      email_verified_at: Time.current
    }.merge(attrs))
  end

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password123" }
  end

  it "lets staff view announcements and only admins create them" do
    staff = create_user(role: :staff)
    admin = create_user(role: :admin)

    sign_in(staff)
    get admin_notifications_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Announcements")
    expect(response.body).to include("Admin Dashboard", "Users", "Notifications", "Back to app")
    expect(response.body).not_to include(app_notifications_path)

    post admin_notifications_path, params: { announcement: { title: "News", body: "Body", audience: "members" } }
    expect(response).to redirect_to(root_path)

    sign_in(admin)
    expect {
      post admin_notifications_path, params: { announcement: { title: "News", body: "Body", action_url: "https://example.test", audience: "members" } }
    }.not_to have_enqueued_job(Notifications::FanOutAnnouncementJob)
    expect(response).to have_http_status(:unprocessable_content)

    expect {
      post admin_notifications_path, params: { announcement: { title: "News", body: "Body", action_url: "/app/dashboard", audience: "members" } }
    }.to have_enqueued_job(Notifications::FanOutAnnouncementJob)

    expect(response).to redirect_to(admin_notifications_path)
    expect(AuditEvent.exists?(action: "admin.notifications.announcement", actor: admin)).to be(true)
  end
end
