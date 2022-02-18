# frozen_string_literal: true

class CreatePgSearchDocuments < ActiveRecord::Migration[6.0]
  def self.up
    remove_column :characters :content
  end

  def self.down
    say_with_time("Dropping table for pg_search multisearch") do
      drop_table :pg_search_documents
    end
  end
end
