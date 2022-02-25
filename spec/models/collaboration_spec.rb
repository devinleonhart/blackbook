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

require "rails_helper"

RSpec.describe Collaboration, type: :model do
  it "should create a valid collaboration" do
    @universe = create(:universe)
    @user = create(:user)
    @collaboration = build(:collaboration, universe: @universe, user: @user)
    expect(@collaboration).to be_valid
  end

  it "should not allow a collaboration with a universe's owner" do
    @owner = create(:user)
    @universe = create(:universe, owner: @owner)
    @collaboration = build(:collaboration, universe: @universe, user: @owner)
    expect(@collaboration).to be_invalid
    expect(@collaboration.errors.full_messages).to eq(["User cannot collaborate on their own universe!"])
  end

  it "should not allow a collaboration multiple times" do
    @user = create(:user)
    @universe = create(:universe)
    @collaboration1 = create(:collaboration, universe: @universe, user: @user)
    @collaboration2 = build(:collaboration, universe: @universe, user: @user)
    expect(@collaboration2).to be_invalid
  end
end
