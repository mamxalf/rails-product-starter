module Notifications
  class Create
    def self.call(user:, kind:, title:, body:, action_url: nil, metadata: {}, dedupe_key: nil)
      if dedupe_key.present?
        existing = user.notifications.find_by(dedupe_key:)
        return existing if existing
      end

      user.notifications.create!(kind:, title:, body:, action_url:, metadata:, dedupe_key:)
    rescue ActiveRecord::RecordNotUnique
      user.notifications.find_by!(dedupe_key:)
    end
  end
end
