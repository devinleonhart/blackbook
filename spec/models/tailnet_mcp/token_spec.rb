# frozen_string_literal: true

require "rails_helper"

# == Schema Information
#
# Table name: mcp_tokens
#
#  id           :bigint           not null, primary key
#  digest       :string           not null
#  expires_at   :datetime         not null
#  last_used_at :datetime
#  machine      :string           not null
#  revoked_at   :datetime
#  scopes       :string           default([]), not null, is an Array
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_mcp_tokens_on_digest   (digest) UNIQUE
#  index_mcp_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe TailnetMcp::Token, type: :model do
  let(:user) { create(:user) }

  def issue(**)
    described_class.issue!(user: user, machine: "cocoa", scopes: ["read"], **)
  end

  it { is_expected.to belong_to(:user) }

  describe ".issue!" do
    it "returns the text of a random token" do
      texts = Array.new(2) { issue }

      expect(texts).to all(match(/\Abbk_[A-Za-z0-9_-]{43}\z/))
      expect(texts.uniq.size).to eq(2)
    end

    it "stores no part of the text" do
      text = issue
      row = described_class.connection.select_one("SELECT * FROM mcp_tokens").values.join(" ")

      expect(row).not_to include(text, text.delete_prefix("bbk_"))
    end

    it "lasts 90 days unless told otherwise" do
      freeze_time do
        issue
        issue(days: 7)

        expect(described_class.order(:id).map(&:expires_at)).to eq([90.days.from_now, 7.days.from_now])
      end
    end

    it "keeps each scope once, in order" do
      issue(scopes: %w[delete read read write])

      expect(described_class.sole.scopes).to eq(%w[read write delete])
    end

    it "refuses bad scopes, machines and lifetimes" do
      [{ scopes: [] }, { scopes: ["admin"] }, { scopes: ["write"] }, { scopes: ["delete"] }, { scopes: %w[read root] },
       { machine: " " }, { days: 0 }, { days: -1 }, { days: 366 }].each do |options|
        expect { issue(**options) }.to raise_error(ActiveRecord::RecordInvalid)
      end
      expect(described_class.count).to eq(0)
    end

    it "allows 365 days" do
      expect { issue(days: 365) }.to change(described_class, :count).by(1)
    end
  end

  describe ".authenticate" do
    let!(:text) { issue }

    it "finds the token of a text" do
      expect(described_class.authenticate(text)).to eq(described_class.sole)
    end

    it "finds nothing for other texts" do
      [nil, "", " ", "bbk_", text.chop, "#{text}x", text.swapcase, " #{text}", text.delete_prefix("bbk_"),
       described_class.sole.digest, "#{text}\u0000", "\xFF"].each do |other|
        expect(described_class.authenticate(other)).to be_nil
      end
    end

    it "finds nothing from the moment of expiry" do
      expires_at = described_class.sole.expires_at
      travel_to(expires_at - 1.second, with_usec: true) { expect(described_class.authenticate(text)).to be_present }
      travel_to(expires_at, with_usec: true) { expect(described_class.authenticate(text)).to be_nil }
    end

    it "finds nothing after revoking" do
      described_class.sole.revoke!

      expect(described_class.authenticate(text)).to be_nil
    end
  end

  describe "#revoke!" do
    it "keeps the first time" do
      token = create(:mcp_token)
      token.revoke!
      first = token.revoked_at
      travel(1.day) { token.revoke! }

      expect(token.reload.revoked_at).to be_within(1.second).of(first)
    end
  end

  it "answers for its scopes" do
    token = build(:mcp_token, scopes: %w[read write])

    expect(token.allows?("read")).to be(true)
    expect(token.allows?(:write)).to be(true)
    expect(token.allows?("delete")).to be(false)
  end

  it "does not show its digest when inspected or serialized" do
    token = create(:mcp_token)

    shown = [token.inspect, token.full_inspect, token.to_json, token.serializable_hash.to_s].join

    expect(shown).not_to include(token.digest)
  end

  it "is deleted with its user" do
    issue

    expect { user.destroy! }.to change(described_class, :count).by(-1)
  end

  it "cannot repeat a digest" do
    token = create(:mcp_token)

    expect { create(:mcp_token, digest: token.digest) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
