# frozen_string_literal: true

require "stringio"

def seed_image_bytes
  path = Rails.root.join("spec/fixtures/files/test_image.jpg")
  return nil unless File.exist?(path)

  File.binread(path)
end

def attach_seed_image!(image, bytes)
  return if bytes.nil?

  image.image_file.attach(
    io: StringIO.new(bytes),
    filename: "seed_image.jpg",
    content_type: "image/jpeg",
  )
end

def create_user!(email:, display_name:, admin: false, password: "password123")
  User.create!(
    email: email,
    display_name: display_name,
    password: password,
    password_confirmation: password,
    admin: admin,
  )
end

def seed_sample_data!
  bytes = seed_image_bytes

  admin = create_user!(email: "admin@blackbook.dev", display_name: "Admin", admin: true)
  owner = create_user!(email: "owner@blackbook.dev", display_name: "Owner")
  collaborator = create_user!(email: "collaborator@blackbook.dev", display_name: "Collaborator")

  universe = Universe.create!(name: "Example Universe", owner: owner)
  Collaboration.create!(universe: universe, user: collaborator)

  admin_universe = Universe.create!(name: "Admin Universe", owner: admin)

  hero = Character.create!(universe: universe, name: "Hero")
  guide = Character.create!(universe: universe, name: "Guide")
  villain = Character.create!(universe: universe, name: "Villain")

  hero.character_tags.create!(name: "protagonist")
  guide.character_tags.create!(name: "mentor")
  villain.character_tags.create!(name: "antagonist")

  images =
    [
      Image.new(universe: universe, caption: "Hero portrait"),
      Image.new(universe: universe, caption: "Villain reveal"),
      Image.new(universe: universe, caption: "The meeting"),
      Image.new(universe: admin_universe, caption: "Admin-only reference"),
    ]

  images.each do |image|
    attach_seed_image!(image, bytes)
    image.save!
  end

  ImageTag.create!(image: images[0], character: hero)
  ImageTag.create!(image: images[1], character: villain)
  ImageTag.create!(image: images[2], character: hero)
  ImageTag.create!(image: images[2], character: guide)

  ImageFavorite.find_or_create_by!(user: owner, image: images[0])
  ImageFavorite.find_or_create_by!(user: collaborator, image: images[2])
  ImageFavorite.find_or_create_by!(user: admin, image: images[3])
end

def clear_dev_data!
  ImageFavorite.delete_all
  ImageTag.delete_all
  CharacterTag.delete_all
  Image.delete_all
  Character.delete_all
  Collaboration.delete_all
  Universe.delete_all
  User.delete_all

  ActiveStorage::Attachment.delete_all
  ActiveStorage::Blob.delete_all
end

return unless Rails.env.development?

Rails.logger.info "Seeding development data..."

ActiveRecord::Base.transaction do
  clear_dev_data!
  seed_sample_data!
end

Rails.logger.info "Seed complete."
Rails.logger.info "Accounts:"
Rails.logger.info "  Admin: admin@blackbook.dev / password123"
Rails.logger.info "  Owner: owner@blackbook.dev / password123"
Rails.logger.info "  Collaborator: collaborator@blackbook.dev / password123"
