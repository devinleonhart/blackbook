# frozen_string_literal: true

class CreateMcpTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :mcp_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :machine, null: false
      t.string :digest, null: false
      t.string :scopes, array: true, null: false, default: []
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.datetime :last_used_at

      t.timestamps
    end
    add_index :mcp_tokens, :digest, unique: true
  end
end
