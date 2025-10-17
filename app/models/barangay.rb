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
end
