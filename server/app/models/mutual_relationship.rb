# frozen_string_literal: true

class MutualRelationship < ApplicationRecord
  has_many :relationships, inverse_of: :mutual_relationship, dependent: :destroy
end
