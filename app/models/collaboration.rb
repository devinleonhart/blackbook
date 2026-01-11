# frozen_string_literal: true

# == Schema Information
#
# Table name: collaborations
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  universe_id :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_collaborations_on_universe_id              (universe_id)
#  index_collaborations_on_user_id                  (user_id)
#  index_collaborations_on_user_id_and_universe_id  (user_id,universe_id) UNIQUE
#
class Collaboration < ApplicationRecord
  validates :user, uniqueness: { scope: :universe_id }

  validate :owner_cannot_be_collaborator

  belongs_to :user, inverse_of: :collaborations
  belongs_to :universe, inverse_of: :collaborations

  private

  def owner_cannot_be_collaborator
    return unless universe&.owner == user

    errors.add(:user, "cannot collaborate on their own universe!")
  end
end
