# frozen_string_literal: true

require "rails_helper"

RSpec.describe SelectOptionHelper, type: :helper do
  describe "#generate_character_names" do
    it "filters out existing tags and sorts case-insensitively" do
      c1 = build_stubbed(:character, id: 1, name: "Zed")
      c2 = build_stubbed(:character, id: 2, name: "alice")
      c3 = build_stubbed(:character, id: 3, name: "Bob")

      existing_tag = double("ImageTag", character: c3)

      result = helper.generate_character_names([c1, c2, c3], [existing_tag])
      expect(result).to eq([["alice", 2], ["Zed", 1]])
    end
  end

  describe "#generate_collaborator_names" do
    it "excludes existing collaborators and the owner, and sorts by display_name" do
      owner = build_stubbed(:user, id: 1, display_name: "Owner")
      u1 = build_stubbed(:user, id: 2, display_name: "Zed")
      u2 = build_stubbed(:user, id: 3, display_name: "Alice")
      u3 = build_stubbed(:user, id: 4, display_name: "Bob")

      existing = [u3]

      result = helper.generate_collaborator_names([owner, u1, u2, u3], existing, owner)
      expect(result).to eq([["Alice", 3], ["Zed", 2]])
    end
  end
end
