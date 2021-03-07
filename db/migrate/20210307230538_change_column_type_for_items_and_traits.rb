class ChangeColumnTypeForItemsAndTraits < ActiveRecord::Migration[6.1]
  change_column :traits, :name, :text

  change_column :items, :name, :text
end
