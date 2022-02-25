# frozen_string_literal: true

# == Schema Information
#
# Table name: relationships
#
#  id                       :bigint           not null, primary key
#  name                     :citext           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  mutual_relationship_id   :integer          not null
#  originating_character_id :integer          not null
#  target_character_id      :integer          not null
#
# Indexes
#
#  index_relationships_on_mutual_relationship_id    (mutual_relationship_id)
#  index_relationships_on_originating_character_id  (originating_character_id)
#  index_relationships_on_target_character_id       (target_character_id)
#  relationships_unique_constraint                  (originating_character_id,target_character_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (originating_character_id => characters.id)
#  fk_rails_...  (target_character_id => characters.id)
#

require "rails_helper"

RSpec.describe Relationship, type: :model do
  # The Relationship model is never meant to be created alone. Test MutualRelationship instead.
end
