class MutualRelationship < ApplicationRecord
  has_many :relationships, inverse_of: :mutual_relationship, dependent: :destroy
end
