# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    subject { build(:item) }

    it { should validate_presence_of(:name) }

    describe 'for uniqueness' do
      subject { create(:item) }

      it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
    end
  end

  it {
    should(
      have_many(:character_items)
      .dependent(:restrict_with_error)
      .inverse_of(:item)
    )
  }
  it {
    should(
      have_many(:characters)
      .through(:character_items)
      .dependent(:restrict_with_error)
      .inverse_of(:items)
    )
  }
end
