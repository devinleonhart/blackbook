# frozen_string_literal: true

class Location < ApplicationRecord
  validates :name, :description, presence: true
  validates :name, uniqueness: { scope: :universe_id, case_sensitive: false }

  belongs_to :universe, inverse_of: :locations
end
