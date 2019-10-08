FactoryBot.define do
  factory :relationship do
    mutual_relationship
    association :originating_character, factory: :character
    association :target_character, factory: :character
    sequence(:name) { |n| "Relationship #{n}" }
  end
end
