class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  # Associations
  belongs_to :barangay, optional: true
  has_many :reports, dependent: :destroy
  has_many :comments, dependent: :destroy

  # User roles
  enum :role, { resident: 0, barangay_official: 1, admin: 2 }, default: :resident

  # Callbacks
  before_validation :normalize_phone_number
  after_update :send_welcome_email_if_confirmed

  # Validations
  VALID_PH_PHONE_REGEX = /\A(\+?63|0)9\d{9}\z/
  validates :phone_number,
            format: { with: VALID_PH_PHONE_REGEX, message: "must be a valid PH mobile (e.g., 09XXXXXXXXX or +639XXXXXXXXX)" },
            allow_blank: true
  validates :phone_number, uniqueness: { case_sensitive: false }, allow_nil: true

  # Scopes
  scope :active, -> { where(deleted_at: nil, banned_at: nil) }
  scope :not_deleted, -> { where(deleted_at: nil) }

  # Devise: block sign-in for banned or soft-deleted users
  def active_for_authentication?
    super && deleted_at.nil? && banned_at.nil?
  end

  def inactive_message
    return :deleted_account if deleted_at.present?
    return :banned if banned_at.present?
    super
  end

  # Management helpers
  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def restore!
    update!(deleted_at: nil, banned_at: nil, ban_reason: nil)
  end

  def ban!(reason: nil)
    update!(banned_at: Time.current, ban_reason: reason)
  end

  def unban!
    update!(banned_at: nil, ban_reason: nil)
  end
  # Residents must select a barangay to prevent spam
  validates :barangay_id, presence: true, if: :resident?

  # Ensure only one barangay official (captain) per barangay
  validates :barangay_id, uniqueness: {
    scope: :role,
    conditions: -> { where(role: :barangay_official) },
    message: "already has a captain assigned"
  }, if: :barangay_official?

  private

  # Normalize Philippine mobile numbers to E.164 (+63XXXXXXXXXX)
  # Examples:
  #  - "09123456789" -> "+639123456789"
  #  - "+639123456789" -> "+639123456789"
  #  - " 09-1234 56789 " -> "+639123456789"
  def normalize_phone_number
    return if phone_number.blank?

    raw = phone_number.to_s.strip.gsub(/[^\d+]/, "")

    # If it starts with 09xxxxxxxxx, convert leading 0 to +63
    if raw.match?(/^09\d{9}$/)
      self.phone_number = "+63" + raw[1..]
      return
    end

    # If it starts with 639xxxxxxxxx (missing plus), add +
    if raw.match?(/^639\d{9}$/)
      self.phone_number = "+" + raw
      return
    end

    # If already in +639xxxxxxxxx keep as is
    if raw.match(/^\+639\d{9}$/)
      self.phone_number = raw
      return
    end

    # Fallback: leave original (validation will catch invalid)
    self.phone_number = raw
  end

  def send_welcome_email_if_confirmed
    # Send welcome email after email confirmation
    if resident? && confirmed_at_changed? && confirmed_at.present?
      ReportMailer.welcome_resident(self).deliver_now
    end
  end
end
