# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :citext           not null
#  display_name           :citext           not null
#  encrypted_password     :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  provider               :string           default("email"), not null
#  uid                    :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  allow_password_change  :boolean          default(FALSE)
#  remember_created_at    :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  tokens                 :json
#

class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User

  # TODO: implement user registration, password recovery, and email confirmation
  devise :database_authenticatable
  # devise :database_authenticatable, :registerable, :recoverable, :confirmable

  validates :email, :display_name, :encrypted_password, presence: true
  validates :email, :display_name, uniqueness: { case_sensitive: false }

  has_one_attached :avatar

  has_many :owned_universes,
    class_name: "Universe",
    foreign_key: "owner_id",
    inverse_of: :owner,
    dependent: :restrict_with_error

  has_many :collaborations, dependent: :destroy, inverse_of: :user
  has_many :contributor_universes, through: :collaborations, class_name:
    "Universe", inverse_of: :collaborators
end
