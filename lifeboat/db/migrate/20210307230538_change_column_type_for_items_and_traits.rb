# frozen_string_literal: true

class ChangeColumnTypeForItemsAndTraits < ActiveRecord::Migration[6.1]
  drop_table :facts
end
