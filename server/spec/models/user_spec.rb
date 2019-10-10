# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :citext           not null
#  display_name    :citext           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user, :with_blank_password) }

    it { should validate_presence_of(:display_name) }

    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:email) }

    describe "for uniqueness" do
      subject { create(:user) }

      it do
        should validate_uniqueness_of(:email).ignoring_case_sensitivity
        should validate_uniqueness_of(:display_name).ignoring_case_sensitivity
      end
    end
  end

  it {
    should(
      have_many(:owned_universes)
      .class_name("Universe")
      .with_foreign_key("owner_id")
      .inverse_of(:owner)
      .dependent(:restrict_with_error)
    )
  }

  it { should have_many(:collaborations).dependent(:destroy).inverse_of(:user) }
  it {
    should(
      have_many(:contributor_universes)
      .through(:collaborations)
      .class_name("Universe")
      .inverse_of(:collaborators)
    )
  }
end
