require 'rails_helper'

RSpec.describe Trait, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }

    describe 'for uniqueness' do
      subject { create(:trait) }

      it { should validate_uniqueness_of(:name) }
    end
  end

  it { should have_many(:character_traits).inverse_of(:trait) }
  it { should have_many(:characters).through(:character_traits).inverse_of(:traits) }
end
