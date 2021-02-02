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

require "rails_helper"

RSpec.describe Trait, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }

    describe "for uniqueness" do
      subject { create(:trait) }

      it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
    end
  end

  it {
    should(
      have_many(:character_traits)
      .dependent(:restrict_with_error)
      .inverse_of(:trait)
    )
  }
  it {
    should(
      have_many(:characters)
      .through(:character_traits)
      .dependent(:restrict_with_error)
      .inverse_of(:traits)
    )
  }
end
