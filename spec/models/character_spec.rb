# frozen_string_literal: true

# == Schema Information
#
# Table name: characters
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :citext           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  universe_id  :bigint           not null
#
# Indexes
#
#  index_characters_on_discarded_at          (discarded_at)
#  index_characters_on_name_and_universe_id  (name,universe_id) UNIQUE
#  index_characters_on_universe_id           (universe_id)
#
# Foreign Keys
#
#  fk_rails_...  (universe_id => universes.id)
#

require "rails_helper"

RSpec.describe Character, type: :model do
  before do
    @universe = FactoryBot.create(:universe)
    @character = FactoryBot.build(:character, { universe: @universe })
    @other_character = FactoryBot.build(:character, { universe: @universe })
    @mutual_relationship = FactoryBot.create(:mutual_relationship, { character1: @character, character2: @other_character })
  end

  it "should not allow a character to have a missing name" do
    @character.name = ""
    expect(@character).to be_invalid
  end

  it "should not allow a duplicate character name" do
    @character.name = "Max Lionheart"
    @character.save
    @other_character.name = "Max Lionheart"
    expect(@other_character).to be_invalid
  end

  it "should list its relationships" do
    expect(@mutual_relationship.relationships).to include(@character.relationships.first)
    expect(@mutual_relationship.relationships).to include(@character.relationships.last)
  end
end
