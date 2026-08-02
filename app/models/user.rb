class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :audit_events, as: :target, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 96, 96 ], preprocessed: true
  end

  enum :role, { member: 0, staff: 1, admin: 2 }, default: :member, validate: true

  normalizes :email_address, with: ->(email) { email.to_s.strip.downcase }

  before_validation :clear_email_verification, if: :persisted_email_change?
  after_update_commit :send_email_verification, if: :saved_change_to_email_address?

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { maximum: 100 }
  validates :preferred_locale, inclusion: { in: %w[id en] }
  validate :avatar_is_supported_image
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

    def avatar_is_supported_image
      return unless avatar.attached?

      detected_type = detected_avatar_content_type

      unless detected_type.in?(%w[image/jpeg image/png image/webp])
        errors.add(:avatar, "must be a JPEG, PNG, or WebP image")
      end

      if avatar.blob.byte_size > 5.megabytes
        errors.add(:avatar, "must be 5 MB or smaller")
      end
    end

    def detected_avatar_content_type
      attachable = attachment_changes["avatar"]&.attachable
      io = attachable.is_a?(Hash) ? attachable[:io] : attachable

      if io.respond_to?(:read)
        io.rewind if io.respond_to?(:rewind)
        Marcel::MimeType.for(io, declared_type: nil)
      else
        avatar.blob.open { |file| Marcel::MimeType.for(file, declared_type: nil) }
      end
    ensure
      io&.rewind if defined?(io) && io.respond_to?(:rewind)
    end

    def time_zone_exists
      TZInfo::Timezone.get(time_zone)
    rescue TZInfo::InvalidTimezoneIdentifier, ArgumentError, TypeError
      errors.add(:time_zone, :inclusion)
    end
end
