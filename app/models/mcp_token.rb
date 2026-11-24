# frozen_string_literal: true

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

# Lets one machine act as a user through MCP, within its scopes. The text is
# shown once, when issued; only its digest is stored.
class McpToken < ApplicationRecord
  SCOPES = %w[read write delete].freeze
  MAX_DAYS = 365
  TEXT = /\Abbk_[A-Za-z0-9_-]{43}\z/

  self.filter_attributes += [:digest]

  belongs_to :user, inverse_of: :mcp_tokens

  normalizes :machine, with: ->(machine) { machine.strip }
  normalizes :scopes, with: ->(scopes) { scopes.uniq.sort_by { |scope| SCOPES.index(scope) || SCOPES.size } }

  validates :machine, :digest, :expires_at, presence: true
  validate :scopes_known
  validate :scopes_include_read
  validate :lifetime_allowed, on: :create

  scope :live, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  def self.issue!(user:, machine:, scopes: ["read"], days: 90)
    generate_text.tap do |text|
      create!(user: user, machine: machine, scopes: scopes, digest: digest_of(text), expires_at: days.days.from_now)
    end
  end

  def self.authenticate(text)
    return unless text.is_a?(String) && text.valid_encoding? && text.match?(TEXT)

    live.find_by(digest: digest_of(text))
  end

  def self.generate_text
    "bbk_#{SecureRandom.urlsafe_base64(32)}"
  end

  # The text is random, so a slow hash would add nothing.
  def self.digest_of(text)
    Digest::SHA256.hexdigest(text)
  end

  def allows?(scope)
    scopes.include?(scope.to_s)
  end

  def revoke!
    update!(revoked_at: Time.current) if revoked_at.nil?
  end

  def serializable_hash(options = nil)
    super.except("digest")
  end

  private

  def scopes_known
    unknown = scopes - SCOPES
    errors.add(:scopes, "are unknown: #{unknown.join(', ')}") if unknown.any?
  end

  def scopes_include_read
    errors.add(:scopes, "must include read") unless allows?(:read)
  end

  def lifetime_allowed
    return if expires_at.nil? || expires_at.between?(Time.current, MAX_DAYS.days.from_now)

    errors.add(:expires_at, "must be within #{MAX_DAYS} days")
  end
end
