# frozen_string_literal: true

# Rename the tag tables to the new domain language: CharacterTag -> Trait (a
# keyword/label on a character) and ImageTag -> Appearance (a character
# appearing in an image). rename_table preserves data and renames the
# convention-named indexes.
class RenameTagModels < ActiveRecord::Migration[8.1]
  def change
    rename_table :character_tags, :traits
    rename_table :image_tags, :appearances
  end
end
