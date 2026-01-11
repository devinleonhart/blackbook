# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  display_name           :citext           not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_display_name          (display_name) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
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
