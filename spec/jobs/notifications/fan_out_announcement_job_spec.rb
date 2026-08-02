require "rails_helper"

RSpec.describe Notifications::FanOutAnnouncementJob, type: :job do
  def create_user(role: :member, **attrs)
    User.create!({
      name: role.to_s.titleize,
      email_address: "#{role}-#{SecureRandom.hex(4)}@example.test",
      password: "password123",
      role: role,
      email_verified_at: Time.current
    }.merge(attrs))
  end

  it "fans out to active audience members idempotently" do
    actor = create_user(role: :admin)
    member = create_user(role: :member)
    create_user(role: :member, suspended_at: Time.current)
    create_user(role: :member, deactivated_at: Time.current)

    2.times do
      described_class.perform_now(
        actor_id: actor.id,
        audience: "all_active",
        title: "Maintenance",
        body: "Tonight",
        action_url: "/app/dashboard",
        announcement_id: "announcement-1"
      )
    end

    expect(member.notifications.pluck(:title)).to eq([ "Maintenance" ])
    expect(actor.notifications.pluck(:title)).to eq([ "Maintenance" ])
  end
end
