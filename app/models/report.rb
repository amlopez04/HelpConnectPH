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
  validate :coordinates_within_city_bounds, if: -> { latitude.present? && longitude.present? }
  validate :resident_single_photo_limit, on: :create, if: -> { user&.resident? }

  # Enums
  enum :status, { pending_approval: 0, pending: 1, in_progress: 2, resolved: 3, closed: 4, reopen_requested: 5 }, default: :pending_approval
  enum :priority, { low: 0, medium: 1, high: 2, critical: 3 }, default: :medium

  # Geocoding
  geocoded_by :address
  after_validation :geocode, if: :should_geocode?
  
  # Handle geocoding errors gracefully
  def geocode
    super
  rescue Timeout::Error => e
    Rails.logger.warn "Geocoding timeout for address: #{address}"
    errors.add(:address, "Geocoding service timed out. Please try again.")
  rescue StandardError => e
    Rails.logger.warn "Geocoding error for address: #{address} - #{e.message}"
    errors.add(:address, "Could not geocode address. Please check and try again.")
  end

  # Only geocode if we don't already have coordinates
  def should_geocode?
    address_changed? && (latitude.blank? || longitude.blank?)
  end

  # Ensure coordinates stay within Parañaque City bounding box
  # Based on Parañaque City center: 14.4793095°N, 121.0198229°E
  # Strict bounds to exclude Las Piñas, Taguig, Pasay, Bacoor, etc.,
  # with allowlisted shared territories (NAIA, Okada, Parqal, Ayala Malls Manila Bay)
  def coordinates_within_city_bounds
    north = 14.5050  # Excludes Pasay/Makati
    south = 14.4580  # Excludes Las Piñas and Bacoor
    east  = 121.0450 # Excludes Taguig
    west  = 120.9730 # Excludes Manila Bay excess area

    lat = latitude.to_f
    lng = longitude.to_f

    outside_bounds = lat > north || lat < south || lng > east || lng < west
    return unless outside_bounds

    # Whitelist shared territories (approximate centers and radii in meters)
    whitelist = [
      { name: 'NAIA Complex',      lat: 14.5108, lng: 121.0196, radius_m: 1500 },
      { name: 'Okada Manila',      lat: 14.5157, lng: 120.9845, radius_m: 600  },
      { name: 'Parqal',            lat: 14.5146, lng: 120.9924, radius_m: 400  },
      { name: 'Ayala Malls Manila Bay', lat: 14.5171, lng: 120.9916, radius_m: 450 }
    ]

    if whitelist.any? { |z| haversine_m(lat, lng, z[:lat], z[:lng]) <= z[:radius_m] }
      return
    end

    errors.add(:base, "Location must be within Parañaque City boundaries")
  end

  # Haversine distance in meters
  def haversine_m(lat1, lng1, lat2, lng2)
    rad = Math::PI / 180.0
    dlat = (lat2 - lat1) * rad
    dlng = (lng2 - lng1) * rad
    a = Math.sin(dlat / 2)**2 + Math.cos(lat1 * rad) * Math.cos(lat2 * rad) * Math.sin(dlng / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    (6371000 * c).abs
  end

  # Check for potential duplicate reports
  def potential_duplicates
    return [] unless latitude.present? && longitude.present?

    # Find reports within 100 meters of this report's location
    # that are in the same category and barangay
    Report.where.not(id: id)
          .where(category: category, barangay: barangay)
          .where(status: [ :pending, :in_progress ])
          .near([ latitude, longitude ], 0.1) # 0.1 km = 100 meters
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
    # - Random/gibberish characters (no meaningful words)
    user_reports_today > 5 || user_reports_this_week > 20 || description.length < 10 || random_gibberish?(description)
  end

  # Validation: Residents can upload up to 3 photos maximum
  def resident_single_photo_limit
    if user&.resident? && photos.attached? && photos.count > 3
      errors.add(:photos, "Residents can upload a maximum of 3 photos per report")
    end
  end

  # Check if text appears to be random gibberish
  def random_gibberish?(text)
    return false if text.blank?
    
    # Remove whitespace and convert to lowercase for analysis
    cleaned = text.downcase.gsub(/\s+/, '')
    return false if cleaned.length < 10 # Too short to analyze
    
    # Count vowels vs consonants
    vowels = cleaned.count('aeiou')
    consonants = cleaned.count('bcdfghjklmnpqrstvwxyz')
    total_letters = vowels + consonants
    
    return false if total_letters == 0
    
    # Random gibberish typically has:
    # - Low vowel-to-consonant ratio (below 30% vowels)
    # - High consonant-to-vowel ratio
    vowel_ratio = vowels.to_f / total_letters
    
    # Check for repetitive patterns (like "abcabc" or "aaaa")
    has_repetitive_pattern = text.scan(/(.)\1{3,}/).any? # Same character repeated 4+ times
    
    # Check if text has very few spaces relative to length (random text usually lacks structure)
    space_count = text.count(' ')
    avg_word_length = space_count > 0 ? text.length.to_f / (space_count + 1) : text.length
    
    # Flag as random gibberish if:
    # 1. Very low vowel ratio (< 20% vowels is suspicious)
    # 2. Has repetitive character patterns
    # 3. Very long words without spaces (avg word length > 15 suggests random text)
    vowel_ratio < 0.20 || has_repetitive_pattern || (space_count == 0 && cleaned.length > 15 && avg_word_length > 15)
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
