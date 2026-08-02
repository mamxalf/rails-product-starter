require "rails_helper"

RSpec.describe Notifications::Create do
  def user
    @user ||= User.create!(name: "Member", email_address: "member@example.test", password: "password123")
  end

  it "creates one notification per user and dedupe key" do
    notification = described_class.call(user:, kind: "system", title: "Title", body: "Body", dedupe_key: "once")
    duplicate = described_class.call(user:, kind: "system", title: "Changed", body: "Body", dedupe_key: "once")

    expect(duplicate).to eq(notification)
    expect(user.notifications.count).to eq(1)
  end
end
