require "rails_helper"

RSpec.describe SecurityMailer, type: :mailer do
  it "uses configured sender and recipient locale for password change notices" do
    user = User.create!(
      name: "Member",
      email_address: "member@example.test",
      password: "password123",
      preferred_locale: "en"
    )

    mail = described_class.password_changed(user)

    expect(mail.from).to eq([ ENV.fetch("MAILER_FROM", "from@example.com") ])
    expect(mail.to).to eq([ user.email_address ])
    expect(mail.subject).to eq("Your password was changed")
  end

  it "sends email change notices to the old address" do
    user = User.create!(
      name: "Member",
      email_address: "new@example.test",
      password: "password123",
      preferred_locale: "en"
    )

    mail = described_class.email_changed(user, "old@example.test")

    expect(mail.to).to eq([ "old@example.test" ])
    expect(mail.subject).to eq("Your email address was changed")
  end
end
