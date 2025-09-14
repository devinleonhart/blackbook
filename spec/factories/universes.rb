# == Schema Information
#
# Table name: universes
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :citext           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :integer          not null
#
# Indexes
#
#  index_universes_on_discarded_at       (discarded_at)
#  index_universes_on_name               (name) UNIQUE
#  index_universes_on_name_and_owner_id  (name,owner_id) UNIQUE
#  index_universes_on_owner_id           (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
FactoryBot.define do
  factory :universe do
    name { "Test Universe" }
    association :owner, factory: :user
  end
end
