# frozen_string_literal: true

# == Schema Information
#
# Table name: characters
#
#  id          :bigint           not null, primary key
#  name        :citext           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  universe_id :bigint           not null
#
# Indexes
#
#  index_characters_on_name_and_universe_id  (name,universe_id) UNIQUE
#  index_characters_on_universe_id           (universe_id)
#
# Foreign Keys
#
#  fk_rails_...  (universe_id => universes.id)
#
class Character < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { scope: :universe_id }

  belongs_to :universe, inverse_of: :characters

  has_many :appearances, inverse_of: :character, dependent: :destroy
  has_many :traits, inverse_of: :character, dependent: :destroy

  # prepend so traits still exist to be counted before dependent: :destroy runs.
  before_destroy :log_character_deletion, prepend: true

  private

  def log_character_deletion
    Rails.logger.info "Character '#{name}' (##{id}) is being deleted with #{traits.count} tags"
  end
end
