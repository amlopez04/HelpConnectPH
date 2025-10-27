class Report < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :barangay
  belongs_to :category
  has_many :comments, dependent: :destroy
  
  # Active Storage - Photo attachments
  has_many_attached :photos
  
  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :address, presence: true
  
  # Enums
  enum :status, { pending_approval: 0, pending: 1, in_progress: 2, resolved: 3, closed: 4, reopen_requested: 5 }, default: :pending_approval
  enum :priority, { low: 0, medium: 1, high: 2, critical: 3 }, default: :medium
  
  # Geocoding
  geocoded_by :address
  after_validation :geocode, if: :should_geocode?

  # Only geocode if we don't already have coordinates
  def should_geocode?
    address_changed? && (latitude.blank? || longitude.blank?)
  end

  # Check for potential duplicate reports
  def potential_duplicates
    return [] unless latitude.present? && longitude.present?
    
    # Find reports within 100 meters of this report's location
    # that are in the same category and barangay
    Report.where.not(id: id)
          .where(category: category, barangay: barangay)
          .where(status: [:pending, :in_progress])
          .near([latitude, longitude], 0.1) # 0.1 km = 100 meters
          .limit(5)
  end

  # Check if this report might be spam
  def potential_spam?
    # Check for suspicious patterns
    user_reports_today = user.reports.where(created_at: 1.day.ago..Time.current).count
    user_reports_this_week = user.reports.where(created_at: 1.week.ago..Time.current).count
    
    # Flag as potential spam if:
    # - More than 5 reports today
    # - More than 20 reports this week
    # - Very short description (less than 10 characters)
    user_reports_today > 5 || user_reports_this_week > 20 || description.length < 10
  end

  # Get admin review status
  def admin_review_status
    if potential_spam?
      "Potential Spam"
    elsif potential_duplicates.any?
      "Potential Duplicate"
    else
      "Normal"
    end
  end
end
