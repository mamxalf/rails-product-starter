module Notifications
  class FanOutAnnouncementJob < ApplicationJob
    queue_as :notifications

    def perform(actor_id:, audience:, title:, body:, action_url:, announcement_id:)
      actor = User.find(actor_id)

      targets_for(audience, actor).find_each do |user|
        Notifications::Create.call(
          user: user,
          kind: "admin_announcement",
          title: title,
          body: body,
          action_url: action_url,
          metadata: { actor_id: actor.id, audience: audience, announcement_id: announcement_id },
          dedupe_key: "#{announcement_id}:#{user.id}"
        )
      end
    end

    private
      def targets_for(audience, actor)
        users = User.where(suspended_at: nil, deactivated_at: nil).where.not(email_verified_at: nil)

        case audience
        when "all_active" then users
        when "members" then users.member
        when "staff" then users.where(role: User.roles.values_at("staff", "admin"))
        else User.none
        end
      end
  end
end
