# frozen_string_literal: true

class DropRelationshipsAndMutualRelationships < ActiveRecord::Migration[7.0]
  def up
    # Drop foreign key constraints first
    remove_foreign_key :relationships, :characters, column: :originating_character_id
    remove_foreign_key :relationships, :characters, column: :target_character_id

    # Drop the tables
    drop_table :relationships
    drop_table :mutual_relationships
  end

  def down
    # Recreate mutual_relationships table
    create_table :mutual_relationships, &:timestamps

    # Recreate relationships table
    create_table :relationships do |t|
      t.integer :mutual_relationship_id, null: false
      t.integer :originating_character_id, null: false
      t.integer :target_character_id, null: false
      t.citext :name, null: false
      t.timestamps
    end

    # Add indexes
    add_index :relationships, :mutual_relationship_id
    add_index :relationships, :originating_character_id
    add_index :relationships, :target_character_id
    add_index :relationships, [:originating_character_id, :target_character_id, :name],
              unique: true, name: "relationships_unique_constraint"

    # Add check constraint
    add_check_constraint :relationships,
                         "originating_character_id <> target_character_id",
                         name: "relationships_no_self_relationships"

    # Add foreign key constraints
    add_foreign_key :relationships, :characters, column: :originating_character_id
    add_foreign_key :relationships, :characters, column: :target_character_id
  end
end
