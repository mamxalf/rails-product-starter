module Admin
  class DashboardController < BaseController
    def show
      @counts = {
        members: User.member.count,
        staff: User.staff.count,
        admins: User.admin.count,
        verified: User.where.not(email_verified_at: nil).count,
        unverified: User.where(email_verified_at: nil).count,
        suspended: User.where.not(suspended_at: nil).count
      }
    end
  end
end
