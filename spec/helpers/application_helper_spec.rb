# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#admin?" do
    it "returns false when there is no current_user" do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.admin?).to be(false)
    end

    it "returns false when current_user is not an admin" do
      user = build_stubbed(:user, admin: false)
      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.admin?).to be(false)
    end

    it "returns true when current_user is an admin" do
      user = build_stubbed(:user, admin: true)
      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.admin?).to be(true)
    end
  end
end
