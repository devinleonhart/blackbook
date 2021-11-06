# frozen_string_literal: true

# == Schema Information
#
# Table name: characters
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :citext           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  universe_id  :bigint           not null
#
# Indexes
#
#  index_characters_on_discarded_at          (discarded_at)
#  index_characters_on_name_and_universe_id  (name,universe_id) UNIQUE
#  index_characters_on_universe_id           (universe_id)
#
# Foreign Keys
#
#  fk_rails_...  (universe_id => universes.id)
#

class Character < ApplicationRecord
  include PgSearch::Model

  multisearchable against: [:name]

  validates :name, presence: true
  validates :name, uniqueness: { scope: :universe_id, case_sensitive: false }

  belongs_to :universe, inverse_of: :characters

  has_many :image_tags, inverse_of: :character, dependent: :destroy
  has_many :images, through: :image_tags, inverse_of: :characters

  has_many :originating_relationships, class_name: "Relationship", foreign_key:
    :originating_character_id, dependent: :destroy, inverse_of:
    :originating_character
  has_many :target_relationships, class_name: "Relationship", foreign_key:
    :target_character_id, dependent: :destroy, inverse_of: :target_character

  def relationships
    originating_relationships + target_relationships
  end
end
