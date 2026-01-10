# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  validates :email, :display_name, :encrypted_password, presence: true
  validates :admin, exclusion: { in: [nil] }
  validates :email, :display_name, uniqueness: { case_sensitive: false }

  has_many :owned_universes,
    class_name: "Universe",
    foreign_key: "owner_id",
    inverse_of: :owner,
    dependent: :restrict_with_error

  has_many :collaborations, dependent: :destroy, inverse_of: :user
  has_many :contributor_universes, through: :collaborations, source: :universe

  has_many :image_favorites, dependent: :destroy
  has_many :favorite_images, through: :image_favorites, source: :image
end
