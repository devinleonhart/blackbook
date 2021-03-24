# frozen_string_literal: true

# == Schema Information
#
# Table name: traits
#
#  id         :bigint           not null, primary key
#  name       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_traits_on_name  (name) UNIQUE
#

require "rails_helper"

RSpec.describe Trait, type: :model do
  before do
    @trait1 = FactoryBot.create(:trait, { name: "Strong" })
  end

  it "should not allow an empty trait name" do
    @trait1.name = ""
    expect(@trait1).to be_invalid
  end

  it "should not allow a nil trait name" do
    @trait1.name = nil
    expect(@trait1).to be_invalid
  end

  it "should not allow a duplicate trait name" do
    @trait2 = FactoryBot.build(:trait, { name: "Strong" })
    expect(@trait2).to be_invalid
  end
end
