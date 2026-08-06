# frozen_string_literal: true

require "rails_helper"

RSpec.describe SelectOptionHelper, type: :helper do
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
