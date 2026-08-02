require "rails_helper"

RSpec.describe Notification, type: :model do
  def user
    @user ||= User.create!(name: "Member", email_address: "member@example.test", password: "password123")
  end

  it "keeps recent unread notifications first and defaults metadata" do
    read = described_class.create!(user:, kind: "system", title: "Read", body: "Body", read_at: 1.hour.ago)
    unread = described_class.create!(user:, kind: "system", title: "Unread", body: "Body")

    expect(described_class.unread).to contain_exactly(unread)
    expect(described_class.recent_first.first).to eq(unread)
    expect(read.metadata).to eq({})
  end

  it "validates kind and internal action URLs" do
    notification = described_class.new(user:, kind: "external", title: "Bad", body: "Body", action_url: "https://example.test")

    expect(notification).not_to be_valid
    expect(notification.errors[:kind]).to be_present
    expect(notification.errors[:action_url]).to be_present

    notification.kind = "admin_announcement"
    notification.action_url = "/app/dashboard"
    expect(notification).to be_valid

    notification.action_url = "//example.test"
    expect(notification).not_to be_valid
  end
end
