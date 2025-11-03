class Barangay < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :address, presence: true

  # Associations
  has_many :reports, dependent: :destroy
  has_many :users, dependent: :nullify

  # Geocoding
  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  # Handle geocoding errors gracefully
  def geocode
    super
  rescue Timeout::Error => e
    Rails.logger.warn "Geocoding timeout for barangay #{name}: #{address}"
    # Don't block creation if geocoding fails
  rescue StandardError => e
    Rails.logger.warn "Geocoding error for barangay #{name}: #{address} - #{e.message}"
    # Don't block creation if geocoding fails
  end
end
