# frozen_string_literal: true

class AddDiscardedAtToCharacters < ActiveRecord::Migration[6.0]
  def change
    add_column :characters, :discarded_at, :datetime
    add_index :characters, :discarded_at
  end
end
