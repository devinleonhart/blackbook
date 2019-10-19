# frozen_string_literal: true

# == Schema Information
#
# Table name: mutual_relationships
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MutualRelationship < ApplicationRecord
  has_many :relationships, inverse_of: :mutual_relationship, dependent: :destroy

  def universe
    relationships.first.originating_character.universe
  end

  # returns an array containing the Character models involved in this
  # relationship
  def characters
    [
      relationships.first&.originating_character,
      relationships.first&.target_character,
      relationships.last&.originating_character,
      relationships.last&.target_character,
    ].compact.uniq
  end
end
