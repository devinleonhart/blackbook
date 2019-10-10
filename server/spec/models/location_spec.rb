# frozen_string_literal: true

# == Schema Information
#
# Table name: locations
#
#  id          :bigint           not null, primary key
#  name        :citext           not null
#  description :string           not null
#  universe_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "rails_helper"

RSpec.describe Location, type: :model do
  describe "validations" do
    subject { build(:location) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }

    describe "for uniqueness" do
      subject { create(:location) }

      it {
        should(
          validate_uniqueness_of(:name)
          .scoped_to(:universe_id)
          .ignoring_case_sensitivity
        )
      }
    end
  end

  it { should belong_to(:universe).required.inverse_of(:locations) }
end
