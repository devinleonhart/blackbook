# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user, :with_blank_password) }

    it { should validate_presence_of(:name) }

    it { should validate_presence_of(:password) }

    describe 'for uniqueness' do
      subject { create(:user) }

      it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
    end
  end

  it {
    should(
      have_many(:owned_universes)
      .class_name('Universe')
      .inverse_of(:owner)
      .dependent(:destroy)
    )
  }

  it { should have_many(:collaborations).dependent(:destroy).inverse_of(:user) }
  it {
    should(
      have_many(:contributor_universes)
      .through(:collaborations)
      .class_name('Universe')
      .inverse_of(:collaborators)
    )
  }
end
