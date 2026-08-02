require "rails_helper"

RSpec.describe User, type: :model do
  it "normalizes email addresses before enforcing uniqueness" do
    described_class.create!(name: "First", email_address: "User@Example.com", password: "password123")

    duplicate = described_class.new(name: "Second", email_address: " user@example.COM ", password: "password123")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email_address]).to be_present
  end

  it "exposes account state predicates" do
    user = described_class.new(email_verified_at: Time.current, suspended_at: Time.current, deactivated_at: Time.current)

    expect(user).to be_email_verified
    expect(user).to be_suspended
    expect(user).to be_deactivated
  end

  it "accepts small jpeg, png, and webp avatars and rejects invalid uploads" do
    user = described_class.new(name: "Member", email_address: "member@example.test", password: "password123")

    {
      "image/jpeg" => "\xff\xd8\xff\xe0\x00\x10JFIF\x00".b,
      "image/png" => "\x89PNG\r\n\x1a\n".b,
      "image/webp" => "RIFF\x1a\x00\x00\x00WEBPVP8 ".b
    }.each do |content_type, bytes|
      user.avatar.attach(io: StringIO.new(bytes), filename: "avatar", content_type:)
      expect(user).to be_valid
      user.avatar.detach
    end

    user.avatar.attach(io: StringIO.new("nope"), filename: "avatar.png", content_type: "image/png")
    expect(user).not_to be_valid

    user.avatar.detach
    user.avatar.attach(io: StringIO.new("x" * (5.megabytes + 1)), filename: "avatar.png", content_type: "image/png")
    expect(user).not_to be_valid
  end
end
