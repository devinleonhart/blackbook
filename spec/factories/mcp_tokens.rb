# frozen_string_literal: true

# == Schema Information
#
# Table name: mcp_tokens
#
#  id           :bigint           not null, primary key
#  digest       :string           not null
#  expires_at   :datetime         not null
#  last_used_at :datetime
#  machine      :string           not null
#  revoked_at   :datetime
#  scopes       :string           default([]), not null, is an Array
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_mcp_tokens_on_digest   (digest) UNIQUE
#  index_mcp_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :mcp_token do
    user
    machine { "cocoa" }
    scopes { ["read"] }
    digest { McpToken.digest_of(McpToken.generate_text) }
    expires_at { 90.days.from_now }
  end
end
