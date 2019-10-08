# frozen_string_literal: true

class Collaboration < ApplicationRecord
  validates :user, uniqueness: { scope: :universe_id }

  belongs_to :user, inverse_of: :collaborations
  belongs_to :universe, inverse_of: :collaborations
end
