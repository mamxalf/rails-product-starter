module Admin
  module Users
    class RevokeSessions
      def self.call(actor:, target:, request: nil)
        raise Error, "Staff cannot modify admins." if actor.staff? && target.admin?

        User.transaction do
          revoked = target.sessions.destroy_all.size
          Auditing::Record.call(
            action: "admin.users.revoke_sessions",
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
