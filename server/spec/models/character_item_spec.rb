# frozen_string_literal: true

# == Schema Information
#
# Table name: character_items
#
#  id           :bigint           not null, primary key
#  character_id :bigint           not null
#  item_id      :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require "rails_helper"

RSpec.describe CharacterItem, type: :model do
  describe "validations" do
    describe "for uniqueness" do
      subject { create(:character_item) }

      it { should validate_uniqueness_of(:character).scoped_to(:item_id) }
    end
  end

  it { should belong_to(:character).required.inverse_of(:character_items) }
  it { should belong_to(:item).required.inverse_of(:character_items) }
end