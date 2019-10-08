require 'rails_helper'

RSpec.describe Collaboration, type: :model do
  describe 'validations' do
    describe 'for uniqueness' do
      subject { create(:collaboration) }

      it { should(
        validate_uniqueness_of(:user)
        .scoped_to(:universe_id)
      ) }
    end
  end

  it { should belong_to(:user).required.inverse_of(:collaborations) }
  it { should belong_to(:universe).required.inverse_of(:collaborations) }
end
