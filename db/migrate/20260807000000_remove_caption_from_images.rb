# frozen_string_literal: true

# Captions were never surfaced in the UI. Dropping the column in favor of a
# simpler image model.
class RemoveCaptionFromImages < ActiveRecord::Migration[8.1]
  def change
    remove_column :images, :caption, :text, default: "", null: false
  end
end
