# frozen_string_literal: true

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
