require "rails_helper"

RSpec.describe "Locales", type: :request do
  def user(locale:)
    User.create!(
      name: "Member",
      email_address: "member-#{locale}@example.com",
      password: "password123",
      preferred_locale: locale,
      email_verified_at: Time.current
    )
  end

  it "defaults guests to Indonesian" do
    get new_session_path

    expect(response.body).to include("Masuk")
  end

  it "lets guests switch to English and keeps it in a signed cookie" do
    patch locale_path, params: { locale: "en" }

    expect(response).to redirect_to(new_session_path)

    get new_session_path
    expect(response.body).to include("Sign in")
  end

  it "does not persist a locale parameter without the switch action" do
    get new_session_path(locale: "en")
    expect(response.body).to include("Sign in")

    get new_session_path
    expect(response.body).to include("Masuk")
  end

  it "uses authenticated preference before the guest cookie" do
    patch locale_path, params: { locale: "en" }
    member = user(locale: "id")

    post session_path, params: { email_address: member.email_address, password: "password123" }
    get app_path

    expect(response.body).to include("Keluar")
  end

  it "falls back safely for unsupported locale values" do
    patch locale_path, params: { locale: "fr" }

    expect(response).to redirect_to(new_session_path)

    get new_session_path
    expect(response.body).to include("Masuk")
  end

  it "updates authenticated user preference on explicit language change" do
    member = user(locale: "id")
    post session_path, params: { email_address: member.email_address, password: "password123" }

    patch locale_path, params: { locale: "en" }

    expect(member.reload.preferred_locale).to eq("en")
  end
end
