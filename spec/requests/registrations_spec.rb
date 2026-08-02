require "rails_helper"

RSpec.describe "Registrations", type: :request do
  it "creates a member account, signs in, and sends verification mail" do
    expect {
      post registration_path, params: {
        user: {
          name: "New Member",
          email_address: "New@Example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "admin",
          email_verified_at: Time.current,
          suspended_at: Time.current
        }
      }
    }.to change(User, :count).by(1)
      .and have_enqueued_mail(EmailVerificationMailer, :verification)

    user = User.last
    expect(user).to be_member
    expect(user.email_address).to eq("new@example.com")
    expect(user.email_verified_at).to be_nil
    expect(user.suspended_at).to be_nil
    expect(response).to redirect_to(app_path)
  end

  it "rerenders invalid registrations with non-password fields preserved" do
    post registration_path, params: {
      user: {
        name: "New Member",
        email_address: "new@example.com",
        password: "short",
        password_confirmation: "different"
      }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("New Member")
    expect(response.body).to include("new@example.com")
    expect(response.body).not_to include("short")
  end
end
