# frozen_string_literal: true

# == Schema Information
#
# Table name: universes
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :citext           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :bigint           not null
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

require "rails_helper"

RSpec.describe Universe, type: :model do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @universe1 = FactoryBot.create(:universe, { name: "Knighthood", owner: @user1 })
  end

  it "should not allow an empty universe name" do
    @universe1.name = ""
    expect(@universe1).to be_invalid
  end

  it "should not allow a nil universe name" do
    @universe1.name = nil
    expect(@universe1).to be_invalid
  end

  it "should allow a duplicate universe name across different owners" do
    @universe2 = FactoryBot.build(:universe, { name: "Knighthood", owner: @user2 })
    expect(@universe2).to be_valid
  end

  it "should not allow a duplicate universe name with same owner" do
    @universe2 = FactoryBot.build(:universe, { name: "Knighthood", owner: @user1 })
    expect(@universe2).to be_invalid
  end
end
