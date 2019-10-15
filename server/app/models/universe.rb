# frozen_string_literal: true

# == Schema Information
#
# Table name: universes
#
#  id           :bigint           not null, primary key
#  name         :citext           not null
#  owner_id     :bigint           not null
#  discarded_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Universe < ApplicationRecord
  include Discard::Model

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  belongs_to :owner, class_name: "User", inverse_of: :owned_universes

  has_many :collaborations, inverse_of: :universe, dependent: :destroy
  has_many :collaborators,
    through: :collaborations, class_name: "User",
    source: :user, inverse_of: :contributor_universes

  has_many :characters, inverse_of: :universe, dependent: :destroy
  has_many :locations, inverse_of: :universe, dependent: :destroy

  # returns a boolean indicating whether the given User model is allowed to
  # view this Universe
  def visible_to_user?(user)
    owner == user || collaborators.include?(user)
  end
end
