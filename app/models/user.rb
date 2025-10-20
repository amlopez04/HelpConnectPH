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
end
