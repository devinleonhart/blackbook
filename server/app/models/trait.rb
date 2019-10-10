# frozen_string_literal: true

# == Schema Information
#
# Table name: traits
#
#  id         :bigint           not null, primary key
#  name       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Trait < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  has_many :character_traits, dependent: :restrict_with_error, inverse_of:
    :trait
  has_many :characters, through: :character_traits, dependent:
    :restrict_with_error, inverse_of: :traits
end
