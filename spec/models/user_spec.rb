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
end
