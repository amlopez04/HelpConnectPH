class Comment < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :report

  # Validations
  validates :content, presence: true, length: { minimum: 3 }

  # Default scope - oldest first (chronological order)
  default_scope { order(created_at: :asc) }
end
