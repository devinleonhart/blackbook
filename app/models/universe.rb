# frozen_string_literal: true

# == Schema Information
#
# Table name: universes
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :citext           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :bigint           not null
#
# Indexes
#
#  index_universes_on_discarded_at       (discarded_at)
#  index_universes_on_name               (name) UNIQUE
#  index_universes_on_name_and_owner_id  (name,owner_id) UNIQUE
#  index_universes_on_owner_id           (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#

class Universe < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: :owner_id }

  belongs_to :owner, class_name: "User", inverse_of: :owned_universes

  has_many :collaborations, inverse_of: :universe, dependent: :destroy
  has_many :collaborators,
    through: :collaborations, class_name: "User",
    source: :user, inverse_of: :contributor_universes

  has_many :characters, inverse_of: :universe, dependent: :destroy
  has_many :images, inverse_of: :universe, dependent: :destroy

  # returns a boolean indicating whether the given User model is allowed to
  # view this Universe
  def visible_to_user?(user)
    owner == user || collaborators.include?(user)
  end
end
