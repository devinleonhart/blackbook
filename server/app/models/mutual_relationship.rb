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
end
