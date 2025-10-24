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
  enum :status, { pending: 0, in_progress: 1, resolved: 2, closed: 3 }, default: :pending
  enum :priority, { low: 0, medium: 1, high: 2, critical: 3 }, default: :medium
  
  # Geocoding
  geocoded_by :address
  after_validation :geocode, if: :should_geocode?

  # Only geocode if we don't already have coordinates
  def should_geocode?
    address_changed? && (latitude.blank? || longitude.blank?)
  end
end
