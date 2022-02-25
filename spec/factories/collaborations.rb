# frozen_string_literal: true

# == Schema Information
#
# Table name: collaborations
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  universe_id :integer          not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_collaborations_on_universe_id              (universe_id)
#  index_collaborations_on_user_id                  (user_id)
#  index_collaborations_on_user_id_and_universe_id  (user_id,universe_id) UNIQUE
#

FactoryBot.define do
  factory :collaboration do
    user
    universe
  end
end
