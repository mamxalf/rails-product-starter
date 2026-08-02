require "rails_helper"

RSpec.describe UserPolicy do
  def user(role)
    User.new(role: role, email_address: "#{role}@example.com", name: role.to_s, password: "password123")
  end

  let(:member) { user(:member) }
  let(:staff) { user(:staff) }
  let(:admin) { user(:admin) }

  it "denies guests" do
    policy = described_class.new(nil, member)

    expect(policy.access_member?).to be(false)
    expect(policy.access_admin?).to be(false)
    expect(policy.manage_staff?).to be(false)
    expect(policy.manage_admins?).to be(false)
  end

  it "maps member, staff, and admin permissions" do
    expect(described_class.new(member, member).access_member?).to be(true)
    expect(described_class.new(member, member).access_admin?).to be(false)
    expect(described_class.new(staff, member).access_admin?).to be(true)
    expect(described_class.new(staff, member).manage_staff?).to be(false)
    expect(described_class.new(admin, staff).manage_staff?).to be(true)
    expect(described_class.new(admin, admin).manage_admins?).to be(true)
  end

  it "blocks self demotion" do
    expect(described_class.new(admin, admin).demote_self?).to be(false)
    expect(described_class.new(admin, staff).demote_self?).to be(true)
  end
end
