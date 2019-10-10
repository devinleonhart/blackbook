# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  # TODO: soft delete instead of hard delete
  has_many :owned_universes,
    class_name: "Universe",
    inverse_of: :owner,
    dependent: :destroy

  has_many :collaborations, dependent: :destroy, inverse_of: :user
  has_many :contributor_universes, through: :collaborations, class_name:
    "Universe", inverse_of: :collaborators
end
