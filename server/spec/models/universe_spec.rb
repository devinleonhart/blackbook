# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Universe, type: :model do
  describe 'validations' do
    subject { build(:universe) }

    it { should validate_presence_of(:name) }

    describe 'for uniqueness' do
      subject { create(:universe) }

      it { should validate_uniqueness_of(:name) }
    end
  end

  it {
    should(
      belong_to(:owner)
      .required
      .inverse_of(:owned_universes)
      .class_name('User')
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
      .class_name('User')
      .inverse_of(:contributor_universes)
    )
  }

  it { should have_many(:characters).inverse_of(:universe).dependent(:destroy) }
  it { should have_many(:locations).inverse_of(:universe).dependent(:destroy) }
end
