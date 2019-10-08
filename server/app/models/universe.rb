# frozen_string_literal: true

class Universe < ApplicationRecord
  include Discard::Model

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  belongs_to :owner, class_name: 'User', inverse_of: :owned_universes

  has_many :collaborations, inverse_of: :universe, dependent: :destroy
  has_many :collaborators, through: :collaborations, class_name: 'User',
                           inverse_of: :contributor_universes

  has_many :characters, inverse_of: :universe, dependent: :destroy
  has_many :locations, inverse_of: :universe, dependent: :destroy
end
