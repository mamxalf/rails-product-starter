class Notification < ApplicationRecord
  KINDS = %w[system admin_announcement].freeze

  belongs_to :user

  scope :unread, -> { where(read_at: nil) }
  scope :recent_first, -> { order(created_at: :desc, id: :desc) }

  validates :kind, inclusion: { in: KINDS }
  validates :title, :body, presence: true
  validate :action_url_is_internal

  private
    def action_url_is_internal
      return if action_url.blank?
      return if action_url.start_with?("/") && !action_url.start_with?("//")

      errors.add(:action_url, "must be an internal path")
    end
end
