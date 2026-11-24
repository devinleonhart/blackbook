# frozen_string_literal: true

namespace :mcp do
  namespace :tokens do
    desc "Issue a token: USER=<email> MACHINE=<name> [SCOPES=read] [DAYS=90]. Prints only the token on stdout"
    task issue: :environment do
      user = User.find_by(email: ENV["USER"].to_s.strip.downcase) || abort("No user has the email in USER")
      scopes = ENV.fetch("SCOPES", "read").split(",").map(&:strip)
      days = Integer(ENV.fetch("DAYS", "90"), 10, exception: false) || abort("DAYS must be a number")

      begin
        text = McpToken.issue!(user: user, machine: ENV["MACHINE"].to_s, scopes: scopes, days: days)
      rescue ActiveRecord::RecordInvalid => error
        abort error.message
      end

      warn "Issued for #{user.email} on #{ENV.fetch('MACHINE')}: #{scopes.join(',')}, #{days} days"
      $stdout.puts text
    end

    desc "List the tokens, without their texts"
    task list: :environment do
      McpToken.includes(:user).order(:id).each do |token|
        state = token.revoked_at ? "revoked #{token.revoked_at.to_fs(:db)}" : "expires #{token.expires_at.to_fs(:db)}"
        used = token.last_used_at ? "last used #{token.last_used_at.to_fs(:db)}" : "never used"
        $stdout.puts [token.id, token.user.email, token.machine, token.scopes.join(","), state, used].join("  ")
      end
    end

    desc "Revoke a token: ID=<id>"
    task revoke: :environment do
      token = McpToken.find_by(id: ENV.fetch("ID", nil)) || abort("No token has the id in ID")
      token.revoke!
      warn "Revoked token #{token.id}"
    end
  end
end
