# frozen_string_literal: true

# == Schema Information
#
# Table name: universes
#
#  id           :bigint           not null, primary key
#  name         :citext           not null
#  owner_id     :bigint           not null
#  discarded_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require "rails_helper"

RSpec.describe Universe, type: :model do
  describe "validations" do
    subject { build(:universe) }

    it { should validate_presence_of(:name) }

    describe "for uniqueness" do
      subject { create(:universe) }

      it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
    end
  end

  it {
    should(
      belong_to(:owner)
      .required
      .inverse_of(:owned_universes)
      .class_name("User")
    )
  }

  it {
    should(
      have_many(:collaborations)
      .inverse_of(:universe)
      .dependent(:destroy)
    )
  }
  it {
    should(
      have_many(:collaborators)
      .through(:collaborations)
      .class_name("User")
      .inverse_of(:contributor_universes)
    )
  }

  it { should have_many(:characters).inverse_of(:universe).dependent(:destroy) }
  it { should have_many(:locations).inverse_of(:universe).dependent(:destroy) }

  describe ".visible_to_user?" do
    let(:owner) { create :user }
    let(:not_owner) { create :user }
    let(:collaborator) { create :user }

    subject(:universe) do
      universe = build(:universe, owner: owner)
      universe.collaborators << collaborator
      universe.save!
      universe
    end

    it "returns true for the universe's owner" do
      expect(universe.visible_to_user?(owner)).to be(true)
    end

    it "returns true for a collaborator on the universe" do
      expect(universe.visible_to_user?(collaborator)).to be(true)
    end

    it "returns false for an unrelated user" do
      expect(universe.visible_to_user?(not_owner)).to be(false)
    end

    it "returns false for nil" do
      expect(universe.visible_to_user?(nil)).to be(false)
    end
  end
end
