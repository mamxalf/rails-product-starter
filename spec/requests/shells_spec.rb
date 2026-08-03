require "rails_helper"

RSpec.describe "Shells", type: :request do
  def create_user(role: :member, **attrs)
    User.create!({
      name: role.to_s.titleize,
      email_address: "#{role}-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      role: role,
      email_verified_at: Time.current
    }.merge(attrs))
  end

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password123" }
  end

  it "renders public pages for guests" do
    [ root_path, about_path, privacy_path, terms_path, contact_path ].each do |path|
      get path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(ENV.fetch("APP_NAME", "Starter App"))
    end

    get root_path
    expect(response.body).to include(new_session_path)
    expect(response.body).to include(new_registration_path)
  end

  it "renders auth pages with labels, errors, and cross-links" do
    get new_session_path
    expect(response.body).to include("Alamat email")
    expect(response.body).to include(new_registration_path)
    expect(response.body).to include(new_password_path)

    post session_path, params: { email_address: "nobody@example.com", password: "wrong" }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Try another email address or password")

    get new_registration_path
    expect(response.body).to include(new_session_path)
  end

  it "protects the member dashboard and keeps /app as a redirect" do
    get app_dashboard_path
    expect(response).to redirect_to(new_session_path)

    user = create_user(email_verified_at: nil)
    sign_in(user)
    get app_dashboard_path
    expect(response).to redirect_to(new_session_path)

    user.update!(email_verified_at: Time.current, suspended_at: Time.current)
    get app_dashboard_path
    expect(response).to redirect_to(new_session_path)

    user.update!(suspended_at: nil)
    get app_path
    expect(response).to redirect_to(app_dashboard_path)

    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Dashboard")
    expect(response.body).to include("Notifications")
    expect(response.body).to include("Settings")
    expect(response.body).not_to include("inertia")
  end

  it "shows admin access in the app sidebar only for staff and admins" do
    member = create_user(role: :member)
    staff = create_user(role: :staff)

    sign_in(member)
    get app_dashboard_path
    expect(response.body).to include("Dashboard", "Notifications", "Settings")
    expect(response.body).not_to include("Admin")

    sign_in(staff)
    get app_dashboard_path
    expect(response.body).to include("Admin")
    expect(response.body).to include(admin_path)
  end

  it "authorizes the admin dashboard and shows real user counts" do
    create_user(role: :member)
    create_user(role: :member, email_verified_at: nil)
    create_user(role: :member, suspended_at: Time.current)
    staff = create_user(role: :staff)

    get admin_path
    expect(response).to redirect_to(new_session_path)

    sign_in(create_user(role: :member))
    get admin_path
    expect(response).to redirect_to(root_path)

    sign_in(staff)
    get admin_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Members")
    expect(response.body).to include("Staff")
    expect(response.body).to include("Unverified")
    expect(response.body).to include("Suspended")
    expect(response.body).to include("Admin Dashboard")
    expect(response.body).to include("Users")
    expect(response.body).to include("Notifications")
    expect(response.body).to include("Audit events")
    expect(response.body).to include("Jobs")
    expect(response.body).to include(app_dashboard_path)
    expect(response.body).not_to include(app_notifications_path)
  end
end
