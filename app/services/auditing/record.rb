module Auditing
  class Record
    def self.call(action:, actor:, target:, metadata: {}, request: nil)
      AuditEvent.create!(
        action: action,
        actor: actor,
        target: target,
        metadata: metadata,
        ip_address: request&.remote_ip,
        user_agent: request&.user_agent
      )
    end
  end
end
