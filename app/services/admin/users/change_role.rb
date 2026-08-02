module Admin
  module Users
    class ChangeRole
      def self.call(actor:, target:, role:, request: nil)
        role = role.to_s
        raise Error, "Role is not valid." unless User.roles.key?(role)
        raise Error, "Staff cannot promote users to admin." if actor.staff? && role == "admin"
        raise Error, "Staff cannot modify admins." if actor.staff? && target.admin?
        raise Error, "Last remaining admin cannot be demoted." if target.admin? && role != "admin" && User.admin.where.not(id: target.id).none?

        User.transaction do
          old_role = target.role
          target.update!(role: role)
          Auditing::Record.call(
            action: "admin.users.change_role",
            actor: actor,
            target: target,
            metadata: { from: old_role, to: role },
            request: request
          )
        end
      end
    end
  end
end
