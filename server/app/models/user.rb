# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :citext           not null
#  display_name    :citext           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User

  # TODO: implement user registration, password recovery, and email confirmation
  devise :database_authenticatable
  # devise :database_authenticatable, :registerable, :recoverable, :confirmable

  validates :email, :display_name, :encrypted_password, presence: true
  validates :email, :display_name, uniqueness: { case_sensitive: false }

  has_many :owned_universes,
    class_name: "Universe",
    foreign_key: "owner_id",
    inverse_of: :owner,
    dependent: :restrict_with_error

  has_many :collaborations, dependent: :destroy, inverse_of: :user
  has_many :contributor_universes, through: :collaborations, class_name:
    "Universe", inverse_of: :collaborators
end