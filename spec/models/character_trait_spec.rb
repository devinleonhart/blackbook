# frozen_string_literal: true

# == Schema Information
#
# Table name: character_traits
#
#  id           :bigint           not null, primary key
#  character_id :bigint           not null
#  trait_id     :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

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

  it { should delegate_method(:universe).to(:character).allow_nil }
end
