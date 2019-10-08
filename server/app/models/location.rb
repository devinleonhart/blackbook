class Location < ApplicationRecord
  validates :name, :description, presence: true
  validates :name, uniqueness: { scope: :universe_id }

  belongs_to :universe, inverse_of: :locations
end
