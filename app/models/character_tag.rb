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
#  index_character_tags_on_character_id           (character_id)
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

  belongs_to :character, inverse_of: :character_tags

  before_validation :normalize_name
  after_destroy :cleanup_orphaned_tags

  # Instance method to clean up after this specific tag is destroyed
  def cleanup_orphaned_tags
    # This callback runs after a tag is destroyed
    # We can use this to log or perform additional cleanup if needed
    Rails.logger.debug { "CharacterTag '#{name}' (ID: #{id}) was destroyed for character #{character_id}" }
  end

  private

  def normalize_name
    self.name = name&.strip&.downcase
  end
end
