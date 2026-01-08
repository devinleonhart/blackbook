# frozen_string_literal: true

# == Schema Information
#
# Table name: collaborations
#
#  id          :bigint           not null, primary key
#  user_id     :integer          not null
#  universe_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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
