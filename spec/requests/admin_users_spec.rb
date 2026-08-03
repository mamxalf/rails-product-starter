require "rails_helper"

RSpec.describe "Admin users", type: :request do
  before do
    AuditEvent.delete_all
    Session.delete_all
    User.delete_all
  end

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

  it "denies guests and members" do
    get admin_users_path
    expect(response).to redirect_to(new_session_path)

    sign_in(create_user(role: :member))
    get admin_users_path
    expect(response).to redirect_to(root_path)
  end

  it "lets staff view users without sensitive fields" do
    staff = create_user(role: :staff)
    member = create_user(name: "Visible Member", email_address: "visible@example.test")

    sign_in(staff)
    get admin_users_path(search: "visible")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Visible Member")
    expect(response.body).to include("Admin Dashboard", "Users", "Notifications", "Back to app")
    expect(response.body).not_to include(app_notifications_path)
    expect(response.body).to include(admin_user_path(member))
    expect(response.body).not_to include("password_digest")
    expect(response.body).not_to include("reset_token")

    get admin_user_path(member)
    expect(response.body).to include("visible@example.test")
    expect(response.body).not_to include("password_digest")
    expect(response.body).not_to include("ip_address")
  end

  it "blocks staff from promoting users to admin or modifying admins" do
    staff = create_user(role: :staff)
    member = create_user(role: :member)
    admin = create_user(role: :admin)

    sign_in(staff)

    patch role_admin_user_path(member), params: { user: { role: "admin" } }
    expect(response).to redirect_to(admin_user_path(member))
    expect(member.reload).to be_member

    patch role_admin_user_path(admin), params: { user: { role: "staff" } }
    expect(response).to redirect_to(admin_user_path(admin))
    expect(admin.reload).to be_admin
  end

  it "lets admins change member and staff roles within rules" do
    admin = create_user(role: :admin)
    member = create_user(role: :member)

    sign_in(admin)

    patch role_admin_user_path(member), params: { user: { role: "staff" } }
    expect(response).to redirect_to(admin_user_path(member))
    expect(member.reload).to be_staff
    expect(AuditEvent.where(action: "admin.users.change_role", target: member).count).to eq(1)
  end

  it "blocks self-suspend and last-admin demotion" do
    admin = create_user(role: :admin)

    sign_in(admin)

    patch role_admin_user_path(admin), params: { user: { role: "staff" } }
    expect(response).to redirect_to(admin_user_path(admin))
    expect(admin.reload).to be_admin

    patch suspend_admin_user_path(admin)
    expect(response).to redirect_to(admin_user_path(admin))
    expect(admin.reload.suspended_at).to be_nil
  end

  it "suspends, unsuspends, revokes sessions, and audits each action" do
    admin = create_user(role: :admin)
    member = create_user(role: :member)
    member.sessions.create!(user_agent: "Other", ip_address: "127.0.0.2")

    sign_in(admin)

    patch suspend_admin_user_path(member)
    expect(response).to redirect_to(admin_user_path(member))
    expect(member.reload.suspended_at).to be_present
    expect(member.sessions.count).to eq(0)
    expect(AuditEvent.exists?(action: "admin.users.suspend", target: member)).to be(true)

    patch unsuspend_admin_user_path(member)
    expect(response).to redirect_to(admin_user_path(member))
    expect(member.reload.suspended_at).to be_nil
    expect(AuditEvent.exists?(action: "admin.users.unsuspend", target: member)).to be(true)

    member.sessions.create!(user_agent: "Other", ip_address: "127.0.0.2")
    patch revoke_sessions_admin_user_path(member)
    expect(response).to redirect_to(admin_user_path(member))
    expect(member.sessions.count).to eq(0)
    expect(AuditEvent.exists?(action: "admin.users.revoke_sessions", target: member)).to be(true)
  end
end
