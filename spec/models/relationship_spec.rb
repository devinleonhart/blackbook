# frozen_string_literal: true

# == Schema Information
#
# Table name: relationships
#
#  id                       :bigint           not null, primary key
#  mutual_relationship_id   :bigint           not null
#  originating_character_id :bigint           not null
#  target_character_id      :bigint           not null
#  name                     :citext           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require "rails_helper"

RSpec.describe Relationship, type: :model do
end
