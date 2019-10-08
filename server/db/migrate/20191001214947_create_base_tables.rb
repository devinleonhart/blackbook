# frozen_string_literal: true

class CreateBaseTables < ActiveRecord::Migration[6.0]
  def up
    create_table :users do |t|
      t.string :name, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :name, unique: true

    create_table :universes do |t|
      t.string :name, null: false
      t.references :owner, null: false, foreign_key: { to_table: 'users' }
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :universes, :name, unique: true
    add_index :universes, :discarded_at

    create_table :collaborations do |t|
      t.references :user, null: false
      t.references :universe, null: false

      t.timestamps
    end
    add_index :collaborations, %i[user_id universe_id], unique: true

    create_table :characters do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.references :universe, null: false, foreign_key: true

      t.timestamps
    end
    add_index :characters, %i[name universe_id], unique: true

    create_table :traits do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :traits, :name, unique: true

    create_table :character_traits do |t|
      t.references :character, null: false, foreign_key: true
      t.references :trait, null: false, foreign_key: true
      t.string :value, null: false

      t.timestamps
    end
    add_index :character_traits, %i[character_id trait_id], unique: true

    create_table :mutual_relationships, &:timestamps

    create_table :relationships do |t|
      t.references :mutual_relationship, null: false
      t.references(
        :originating_character,
        null: false,
        foreign_key: { to_table: 'characters' }
      )
      t.references(
        :target_character,
        null: false,
        foreign_key: { to_table: 'characters' }
      )
      t.string :name, null: false

      t.timestamps
    end
    add_index(
      :relationships,
      %i[originating_character_id target_character_id name],
      unique: true,
      name: 'relationships_unique_constraint'
    )
    execute <<-SQL
      ALTER TABLE relationships
      ADD CONSTRAINT relationships_no_self_relationships
      CHECK (originating_character_id <> target_character_id)
    SQL

    create_table :items do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :items, :name, unique: true

    create_table :character_items do |t|
      t.references :character, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
    add_index :character_items, %i[character_id item_id], unique: true

    create_table :locations do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.references :universe, null: false, foreign_key: true

      t.timestamps
    end
    add_index :locations, %i[name universe_id], unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
