# frozen_string_literal: true

# == Schema Information
#
# Table name: characters
#
#  id           :bigint           not null, primary key
#  name         :citext           not null
#  description  :string           not null
#  universe_id  :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

require "rails_helper"

RSpec.describe Character, type: :model do
  describe "validations" do
    subject { build(:character) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }

    describe "for uniqueness" do
      subject { create(:character) }

      it {
        should(
          validate_uniqueness_of(:name)
          .scoped_to(:universe_id)
          .ignoring_case_sensitivity
        )
      }
    end
  end

  it { should belong_to(:universe).required.inverse_of(:characters) }

  it {
    should(
      have_many(:character_traits)
      .inverse_of(:character)
      .dependent(:destroy)
    )
  }
  it {
    should(
      have_many(:traits)
      .through(:character_traits)
      .inverse_of(:characters)
    )
  }

  it {
    should(
      have_many(:character_items)
      .inverse_of(:character)
      .dependent(:destroy)
    )
  }
  it {
    should(
      have_many(:items)
      .through(:character_items)
      .inverse_of(:characters)
    )
  }

  it {
    should(
      have_many(:originating_relationships)
      .class_name("Relationship")
      .with_foreign_key(:originating_character_id)
      .dependent(:destroy)
      .inverse_of(:originating_character)
    )
  }
  it {
    should(
      have_many(:target_relationships)
      .class_name("Relationship")
      .with_foreign_key(:target_character_id)
      .dependent(:destroy)
      .inverse_of(:target_character)
    )
  }
  it { should respond_to(:relationships) }

  it {
    should(
      have_many(:image_tags)
      .inverse_of(:character)
      .dependent(:destroy)
    )
  }
  it {
    should(
      have_many(:images)
      .through(:image_tags)
      .inverse_of(:characters)
    )
  }
end
