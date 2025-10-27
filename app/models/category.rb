class Category < ApplicationRecord
  # Validations
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }

  # Associations
  has_many :reports, dependent: :destroy

  # Default scope - alphabetical order
  default_scope { order(name: :asc) }

  # Normalize name to title case before validation
  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.titleize if name.present?
  end
end
