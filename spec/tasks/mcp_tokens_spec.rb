# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "McpTokenTasks" do
  let!(:user) { create(:user, email: "owner@example.com") }

  before(:all) { Rails.application.load_tasks if Rake::Task.tasks.empty? } # rubocop:disable RSpec/BeforeAfterAll

  # Runs a task with variables, and gives what it printed to each stream and whether it succeeded.
  def run_task(name, variables = {})
    out = StringIO.new
    err = StringIO.new
    original = [$stdout, $stderr, ENV.to_h]
    $stdout = out
    $stderr = err
    ENV.update(variables)
    Rake::Task[name].reenable
    Rake::Task[name].invoke
    [out.string, err.string, true]
  rescue SystemExit => error
    [out.string, err.string, error.success?]
  ensure
    $stdout, $stderr = original
    ENV.replace(original.last)
  end

  describe "mcp:tokens:issue" do
    it "prints only the text on stdout" do
      out, err, success = run_task("mcp:tokens:issue", "USER" => "owner@example.com", "MACHINE" => "cocoa")

      expect(success).to be(true)
      expect(out).to match(/\Abbk_[A-Za-z0-9_-]{43}\n\z/)
      expect(err).to include("cocoa", "read")
      expect(err).not_to include(out.strip)
      expect(TailnetMcp::Token.authenticate(out.chomp))
        .to have_attributes(user: user, machine: "cocoa", scopes: ["read"])
    end

    it "takes scopes and days" do
      freeze_time do
        run_task("mcp:tokens:issue", "USER" => "owner@example.com", "MACHINE" => "pepper",
                                     "SCOPES" => "read, write", "DAYS" => "7")

        expect(TailnetMcp::Token.sole).to have_attributes(scopes: %w[read write], expires_at: 7.days.from_now)
      end
    end

    it "fails without printing on stdout" do
      [{ "USER" => "nobody@example.com", "MACHINE" => "cocoa" }, { "MACHINE" => "cocoa", "USER" => nil },
       { "USER" => "owner@example.com", "MACHINE" => nil },
       { "USER" => "owner@example.com", "MACHINE" => "cocoa", "SCOPES" => "admin" },
       { "USER" => "owner@example.com", "MACHINE" => "cocoa", "DAYS" => "soon" },
       { "USER" => "owner@example.com", "MACHINE" => "cocoa", "DAYS" => "400" }].each do |variables|
        out, err, success = run_task("mcp:tokens:issue", variables)

        expect([out, success]).to eq(["", false])
        expect(err).not_to be_empty
      end
      expect(TailnetMcp::Token.count).to eq(0)
    end
  end

  describe "mcp:tokens:list" do
    it "shows each token without its text or digest" do
      text = TailnetMcp::Token.issue!(user: user, machine: "cocoa", scopes: %w[read write])
      used = create(:mcp_token, user: user, machine: "pepper", last_used_at: Time.utc(2026, 1, 2, 3, 4))
      used.revoke!
      out, = run_task("mcp:tokens:list")

      expect(out.lines.size).to eq(2)
      expect(out.lines.first).to include("owner@example.com", "cocoa", "read,write", "expires", "never used")
      expect(out.lines.last).to include("pepper", "revoked", "2026-01-02 03:04")
      expect(out).not_to include(text)
      TailnetMcp::Token.find_each { |token| expect(out).not_to include(token.digest) }
    end
  end

  describe "mcp:tokens:revoke" do
    it "revokes one token" do
      text = TailnetMcp::Token.issue!(user: user, machine: "cocoa", scopes: ["read"])
      other = create(:mcp_token)
      _, _, success = run_task("mcp:tokens:revoke", "ID" => TailnetMcp::Token.authenticate(text).id.to_s)

      expect(success).to be(true)
      expect(TailnetMcp::Token.authenticate(text)).to be_nil
      expect(other.reload.revoked_at).to be_nil
    end

    it "fails for an unknown id" do
      [{ "ID" => "999999" }, { "ID" => nil }].each do |variables|
        expect(run_task("mcp:tokens:revoke", variables).last).to be(false)
      end
    end
  end
end
