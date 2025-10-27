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
  after_update :send_welcome_email_if_confirmed

  # Validations
  # Residents must select a barangay to prevent spam
  validates :barangay_id, presence: true, if: :resident?

  # Ensure only one barangay official (captain) per barangay
  validates :barangay_id, uniqueness: {
    scope: :role,
    conditions: -> { where(role: :barangay_official) },
    message: "already has a captain assigned"
  }, if: :barangay_official?

  private

  def send_welcome_email_if_confirmed
    # Send welcome email after email confirmation
    if resident? && confirmed_at_changed? && confirmed_at.present?
      ReportMailer.welcome_resident(self).deliver_now
    end
  end
end
