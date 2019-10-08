require 'rails_helper'

RSpec.describe Relationship, type: :model do
  describe 'validations' do
    subject { build(:relationship) }

    it { should validate_presence_of(:name) }

    describe 'for uniqueness' do
      subject { create(:relationship) }

      it { should(
        validate_uniqueness_of(:name)
        .scoped_to([:originating_character_id, :target_character_id])
      )}
    end
  end

  it { should belong_to(:mutual_relationship).required.inverse_of(:relationships) }

  it { should belong_to(:originating_character).required.class_name("Character").inverse_of(:originating_relationships) }

  it { should belong_to(:target_character).required.class_name("Character").inverse_of(:target_relationships) }
end
