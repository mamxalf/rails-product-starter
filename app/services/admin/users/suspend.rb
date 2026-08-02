module Admin
  module Users
    class Suspend
      def self.call(actor:, target:, request: nil)
        raise Error, "Staff cannot modify admins." if actor.staff? && target.admin?
        raise Error, "You cannot suspend your own account." if actor == target

        User.transaction do
          target.update!(suspended_at: Time.current)
          revoked = target.sessions.destroy_all.size
          Auditing::Record.call(
            action: "admin.users.suspend",
            actor: actor,
            target: target,
            metadata: { sessions_revoked: revoked },
            request: request
          )
        end
      end
    end
  end
end
