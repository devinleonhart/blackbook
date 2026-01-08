# frozen_string_literal: true

class RemoveFactsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :facts, if_exists: true
  end
end
