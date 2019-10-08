class CreateBaseTables < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :name, unique: true

    create_table :universes do |t|
      t.string :name, null: false
      t.references :owner, null: false, foreign_key: { to_table: "users" }
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
    add_index :collaborations, [:user_id, :universe_id], unique: true

    create_table :characters do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.references :universe, null: false, foreign_key: true

      t.timestamps
    end
    add_index :characters, [:name, :universe_id], unique: true

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
    add_index :character_traits, [:character_id, :trait_id], unique: true

    create_table :mutual_relationships do |t|
      t.timestamps
    end

    create_table :relationships do |t|
      t.references :mutual_relationship, null: false
      t.references :originating_character, null: false, foreign_key: { to_table: "characters" }
      t.references :target_character, null: false, foreign_key: { to_table: "characters" }
      t.string :name, null: false

      t.timestamps
    end
    add_index(
      :relationships,
      [:originating_character_id, :target_character_id, :name],
      unique: true,
      name: "relationships_unique_constraint"
    )
    execute "ALTER TABLE relationships ADD CONSTRAINT relationships_no_self_relationships CHECK (originating_character_id <> target_character_id)"

    create_table :items do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :items, :name, unique: true

    create_table :character_items do |t|
      t.references :character, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
    end
    add_index :character_items, [:character_id, :item_id], unique: true

    create_table :locations do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.references :universe, null: false, foreign_key: true
    end
    add_index :locations, [:name, :universe_id], unique: true
  end
end
