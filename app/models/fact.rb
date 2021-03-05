# frozen_string_literal: true

class Fact < ApplicationRecord
  validates :fact_type, presence: true
  validates :content, presence: true
  belongs_to :character, inverse_of: :facts, optional: true
  belongs_to :location, inverse_of: :facts, optional: true
end
