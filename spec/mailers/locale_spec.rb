require "rails_helper"

RSpec.describe "Mailer locales", type: :mailer do
  it "renders using the recipient locale" do
    user = User.create!(
      name: "Member",
      email_address: "member@example.com",
      password: "password123",
      preferred_locale: "id"
    )

    mail = PasswordsMailer.reset(user)

    expect(mail.subject).to eq("Atur ulang kata sandi")
    expect(mail.text_part.body.to_s).to include("Tautan ini akan kedaluwarsa")
  end
end
