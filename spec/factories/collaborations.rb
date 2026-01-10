# frozen_string_literal: true

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
