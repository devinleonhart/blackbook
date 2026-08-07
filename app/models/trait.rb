# frozen_string_literal: true

# == Schema Information
#
# Table name: traits
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#
# Indexes
#
#  index_traits_on_character_id           (character_id)
#  index_traits_on_character_id_and_name  (character_id,name) UNIQUE
#  index_traits_on_name                   (name)
#
# Foreign Keys
#
#  fk_rails_...  (character_id => characters.id)
#
class Trait < ApplicationRecord
  # Names are stored lowercased + stripped, so uniqueness needs no
  # case_sensitive flag and presence subsumes the old length check.
  normalizes :name, with: ->(name) { name.strip.downcase }

  validates :name, presence: true
  validates :name, uniqueness: { scope: :character_id }

  belongs_to :character, inverse_of: :traits

  after_destroy :log_tag_destruction

  private

  # Log-only observability hook for tag deletions.
  def log_tag_destruction
    Rails.logger.debug { "Trait '#{name}' (ID: #{id}) was destroyed for character #{character_id}" }
  end
end
