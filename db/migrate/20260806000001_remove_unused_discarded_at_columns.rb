# frozen_string_literal: true

# Remove orphaned soft-delete infrastructure. There is no `discard` gem and
# nothing in the app reads `discarded_at` / `kept` / `.discard` — the columns
# and their indexes were dead. (remove_column drops the dependent index too.)
class RemoveUnusedDiscardedAtColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :universes, :discarded_at, :datetime, precision: nil
    remove_column :characters, :discarded_at, :datetime, precision: nil
  end
end
