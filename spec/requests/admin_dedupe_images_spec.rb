# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin dedupe images", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "shows duplicate groups for admins" do
    admin = create(:user, password: "password123", admin: true)
    universe = create(:universe, owner: admin, name: "Dupes Universe")
    create(:image, universe: universe)
    create(:image, universe: universe)

    sign_in_as(admin)
    get admin_dedupe_images_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Duplicate images")
    expect(response.body).to include("Dupes Universe")
    expect(response.body).to include("identical file data")
  end

  it "keeps the earliest image and deletes the others for a duplicate group" do
    admin = create(:user, password: "password123", admin: true)
    universe = create(:universe, owner: admin)
    img1 = create(:image, universe: universe)
    img2 = create(:image, universe: universe)

    sign_in_as(admin)

    # Make img1 the earliest so we can assert it is kept.
    img1.update!(created_at: 2.days.ago, updated_at: 2.days.ago)
    img2.update!(created_at: 1.day.ago, updated_at: 1.day.ago)

    checksum = img1.image_file.blob.checksum
    byte_size = img1.image_file.blob.byte_size
    content_type = img1.image_file.blob.content_type

    expect do
      post admin_dedupe_images_dedupe_group_path, params: {
        universe_id: universe.id,
        checksum: checksum,
        byte_size: byte_size,
        content_type: content_type,
      }
    end.to change(Image, :count).by(-1)

    expect(Image.exists?(img1.id)).to be(true)
    expect(Image.exists?(img2.id)).to be(false)
  end

  it "dedupes all duplicate groups for a universe in one request" do
    admin = create(:user, password: "password123", admin: true)
    universe = create(:universe, owner: admin, name: "BulkDupes Universe")

    # Create a 3-image duplicate group and a separate 2-image duplicate group
    img_a1 = create(:image, universe: universe)
    img_a2 = create(:image, universe: universe)
    img_a3 = create(:image, universe: universe)

    img_b1 = create(:image, universe: universe)
    img_b2 = create(:image, universe: universe)

    # Force groups A and B to have different blob checksums so we get 2 groups.
    # (Factories may attach the same fixture by default.)
    img_a1.image_file.blob.update!(checksum: "AAAAAAAAAAAAAAAAAAAAAA==")
    img_a2.image_file.blob.update!(checksum: "AAAAAAAAAAAAAAAAAAAAAA==")
    img_a3.image_file.blob.update!(checksum: "AAAAAAAAAAAAAAAAAAAAAA==")

    img_b1.image_file.blob.update!(checksum: "BBBBBBBBBBBBBBBBBBBBBB==")
    img_b2.image_file.blob.update!(checksum: "BBBBBBBBBBBBBBBBBBBBBB==")

    # Make the first image in each group the earliest so we can assert it is kept.
    img_a1.update!(created_at: 3.days.ago, updated_at: 3.days.ago)
    img_a2.update!(created_at: 2.days.ago, updated_at: 2.days.ago)
    img_a3.update!(created_at: 1.day.ago, updated_at: 1.day.ago)

    img_b1.update!(created_at: 2.days.ago, updated_at: 2.days.ago)
    img_b2.update!(created_at: 1.day.ago, updated_at: 1.day.ago)

    sign_in_as(admin)

    expect do
      post admin_dedupe_images_dedupe_universe_path, params: { universe_id: universe.id }
    end.to change { Image.where(universe_id: universe.id).count }.by(-3)

    expect(Image.exists?(img_a1.id)).to be(true)
    expect(Image.exists?(img_a2.id)).to be(false)
    expect(Image.exists?(img_a3.id)).to be(false)

    expect(Image.exists?(img_b1.id)).to be(true)
    expect(Image.exists?(img_b2.id)).to be(false)
  end
end
