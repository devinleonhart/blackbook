# frozen_string_literal: true

# == Schema Information
#
# Table name: collaborations
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  universe_id :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_collaborations_on_universe_id              (universe_id)
#  index_collaborations_on_user_id                  (user_id)
#  index_collaborations_on_user_id_and_universe_id  (user_id,universe_id) UNIQUE
#
FactoryBot.define do
  factory :collaboration do
    association :user
    association :universe

    # Ensure the user is not the owner of the universe
    after(:build) do |collaboration|
      collaboration.user = create(:user) if collaboration.universe && collaboration.user == collaboration.universe.owner
    end
  end
end
