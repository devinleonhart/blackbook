# frozen_string_literal: true

require "rails_helper"

RSpec.describe CharacterTrait, type: :model do
  describe "validations" do
    describe "for uniqueness" do
      subject { create(:character_trait) }

      it { should validate_uniqueness_of(:character).scoped_to(:trait_id) }
    end
  end

  it { should belong_to(:character).required.inverse_of(:character_traits) }
  it { should belong_to(:trait).required.inverse_of(:character_traits) }
end
