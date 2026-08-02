class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one_attached :avatar

  enum :role, { member: 0, staff: 1, admin: 2 }, default: :member, validate: true

  normalizes :email_address, with: ->(email) { email.to_s.strip.downcase }

  before_validation :clear_email_verification, if: :persisted_email_change?
  after_update_commit :send_email_verification, if: :saved_change_to_email_address?

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { maximum: 100 }
  validates :preferred_locale, inclusion: { in: %w[id en] }
  validate :time_zone_exists

  def email_verified?
    email_verified_at.present?
  end

  def suspended?
    suspended_at.present?
  end

  def deactivated?
    deactivated_at.present?
  end

  private
    def clear_email_verification
      self.email_verified_at = nil
    end

    def persisted_email_change?
      persisted? && will_save_change_to_email_address?
    end

    def send_email_verification
      EmailVerificationMailer.verification(self).deliver_later
    end

    def time_zone_exists
      TZInfo::Timezone.get(time_zone)
    rescue TZInfo::InvalidTimezoneIdentifier, ArgumentError, TypeError
      errors.add(:time_zone, :inclusion)
    end
end
