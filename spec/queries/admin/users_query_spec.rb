require "rails_helper"

RSpec.describe "Admin::UsersQuery" do
  before do
    AuditEvent.delete_all
    Session.delete_all
    User.delete_all
  end

  def create_user(name:, email_address:, role: :member, email_verified_at: Time.current, suspended_at: nil, **attrs)
    User.create!(
      {
        name: name,
        email_address: email_address,
        password: "password123",
        role: role,
        email_verified_at: email_verified_at,
        suspended_at: suspended_at
      }.merge(attrs)
    )
  end

  it "searches by name or email" do
    alice = create_user(name: "Alice Admin", email_address: "alice@example.test")
    bob = create_user(name: "Bob Member", email_address: "person@example.test")

    expect(query(search: "alice").relation).to contain_exactly(alice)
    expect(query(search: "person").relation).to contain_exactly(bob)
  end

  it "filters by role, verification, and suspension state" do
    admin = create_user(name: "Admin", email_address: "admin@example.test", role: :admin)
    staff = create_user(name: "Staff", email_address: "staff@example.test", role: :staff, email_verified_at: nil)
    suspended = create_user(name: "Suspended", email_address: "suspended@example.test", suspended_at: Time.current)

    expect(query(role: "admin").relation).to contain_exactly(admin)
    expect(query(verification: "verified").relation).to contain_exactly(admin, suspended)
    expect(query(verification: "unverified").relation).to contain_exactly(staff)
    expect(query(status: "active").relation).to contain_exactly(admin, staff)
    expect(query(status: "suspended").relation).to contain_exactly(suspended)
  end

  it "sorts newest and oldest" do
    old = create_user(name: "Old", email_address: "old@example.test", created_at: 2.days.ago)
    new = create_user(name: "New", email_address: "new@example.test", created_at: 1.day.ago)

    expect(query(sort: "newest").relation).to eq([ new, old ])
    expect(query(sort: "oldest").relation).to eq([ old, new ])
  end

  it "returns a relation ready for pagination" do
    create_user(name: "Member", email_address: "member@example.test")

    relation = query.relation

    expect(relation).to be_a(ActiveRecord::Relation)
    expect(relation.limit(1).to_a.size).to eq(1)
  end

  def query(**params)
    "Admin::UsersQuery".constantize.new(**params)
  end
end
