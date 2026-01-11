# frozen_string_literal: true

# == Schema Information
#
# Table name: characters
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :citext           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  universe_id  :bigint           not null
#
# Indexes
#
#  index_characters_on_discarded_at          (discarded_at)
#  index_characters_on_name_and_universe_id  (name,universe_id) UNIQUE
#  index_characters_on_universe_id           (universe_id)
#
# Foreign Keys
#
#  fk_rails_...  (universe_id => universes.id)
#
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
