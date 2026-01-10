# frozen_string_literal: true

class Character < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { scope: :universe_id, case_sensitive: false }

  belongs_to :universe, inverse_of: :characters

  has_many :image_tags, inverse_of: :character, dependent: :destroy
  has_many :images, through: :image_tags, inverse_of: :characters
  has_many :character_tags, inverse_of: :character, dependent: :destroy

  # After a character is destroyed, we don't need to clean up tags
  # because the dependent: :destroy on character_tags handles this
  # However, we can add logging if needed
  after_destroy :log_character_deletion

  private

  def log_character_deletion
    Rails.logger.info "Character '#{name}' (ID: #{id}) was deleted along with #{character_tags.count} character tags"
  end
end
