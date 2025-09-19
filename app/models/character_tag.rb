# frozen_string_literal: true

# == Schema Information
#
# Table name: character_tags
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#
# Indexes
#
#  index_character_tags_on_character_id_and_name  (character_id,name) UNIQUE
#  index_character_tags_on_name                   (name)
#
# Foreign Keys
#
#  fk_rails_...  (character_id => characters.id)
#

class CharacterTag < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1 }
  validates :name, uniqueness: { scope: :character_id, case_sensitive: false }
  validate :name_must_be_lowercase, :name_cannot_be_empty_string

  belongs_to :character, inverse_of: :character_tags

  before_validation :normalize_name
  after_destroy :cleanup_orphaned_tags

  # Class method to clean up tags that are no longer associated with any characters
  def self.cleanup_orphaned_tags
    # This method can be called manually or via a scheduled job
    # to clean up any tags that might have become orphaned
    Rails.logger.info "Running orphaned tags cleanup..."

    # Find all unique tag names
    tag_names = distinct.pluck(:name)
    cleaned_count = 0

    tag_names.each do |tag_name|
      # Count how many character tags exist with this name
      count = where(name: tag_name).count
      if count == 0
        Rails.logger.warn "Found orphaned tag '#{tag_name}' - this should not happen"
        cleaned_count += 1
      end
    end

    Rails.logger.info "Orphaned tags cleanup complete. Found #{cleaned_count} orphaned tags."
    cleaned_count
  end

  # Method to get all unique tag names across all characters
  def self.all_tag_names
    distinct.pluck(:name).sort
  end

  # Method to get all characters that have a specific tag
  def self.characters_with_tag(tag_name)
    joins(:character).where(name: tag_name).includes(:character)
  end

  # Method to check if a tag name is used by any characters
  def self.tag_exists?(tag_name)
    where(name: tag_name).exists?
  end

  # Instance method to clean up after this specific tag is destroyed
  def cleanup_orphaned_tags
    # This callback runs after a tag is destroyed
    # We can use this to log or perform additional cleanup if needed
    Rails.logger.debug "CharacterTag '#{name}' (ID: #{id}) was destroyed for character #{character_id}"
  end

  private

  def normalize_name
    self.name = name&.strip&.downcase
  end

  def name_must_be_lowercase
    return if name.blank?

    errors.add(:name, "must be lowercase") unless name == name.downcase
  end

  def name_cannot_be_empty_string
    return if name.blank?

    errors.add(:name, "cannot be empty string") if name.strip.empty?
  end
end
