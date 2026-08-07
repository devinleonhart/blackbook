# frozen_string_literal: true

# Universe names are unique per owner (enforced by the composite
# [name, owner_id] unique index and the model's scoped uniqueness
# validation). The standalone global unique index on `name` contradicted
# that rule, causing RecordNotUnique when two owners chose the same name.
class RemoveGlobalUniqueIndexOnUniverseName < ActiveRecord::Migration[8.1]
  def change
    remove_index :universes, :name, unique: true, name: "index_universes_on_name"
  end
end
