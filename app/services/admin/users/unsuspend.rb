module Admin
  module Users
    class Unsuspend
      def self.call(actor:, target:, request: nil)
        raise Error, "Staff cannot modify admins." if actor.staff? && target.admin?

        User.transaction do
          target.update!(suspended_at: nil)
          Auditing::Record.call(action: "admin.users.unsuspend", actor: actor, target: target, request: request)
        end
      end
    end
  end
end
