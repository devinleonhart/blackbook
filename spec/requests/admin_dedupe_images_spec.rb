# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin dedupe images", type: :request do
  let(:admin) { create(:user, admin: true) }
  let(:universe) { create(:universe, owner: admin) }

  before { sign_in(admin) }

  describe "GET index" do
    it "shows duplicate groups" do
      universe = create(:universe, owner: admin, name: "Dupes Universe")
      create(:image, universe: universe)
      create(:image, universe: universe)

      get admin_dedupe_images_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Duplicate images", "Dupes Universe", "identical file data")
    end

    it "lists the individual images belonging to each duplicate group" do
      img1 = create(:image, universe: universe)
      img2 = create(:image, universe: universe)

      get admin_dedupe_images_path

      expect(response.body).to include("Image ##{img1.id}", "Image ##{img2.id}")
    end
  end

  describe "POST dedupe_universe" do
    it "reports when a universe has no duplicates" do
      create(:image, universe: universe) # single image => no duplicate groups

      post admin_dedupe_images_dedupe_universe_path, params: { universe_id: universe.id }

      expect(response).to redirect_to(admin_dedupe_images_url)
      expect(flash[:success]).to include("No duplicate")
    end

    it "shows an error when the universe does not exist" do
      post admin_dedupe_images_dedupe_universe_path, params: { universe_id: Universe.maximum(:id).to_i + 1 }

      expect(response).to redirect_to(admin_dedupe_images_url)
      expect(flash[:error]).to include("Universe not found")
    end

    it "dedupes every duplicate group in one request, keeping the earliest of each" do
      universe = create(:universe, owner: admin, name: "BulkDupes Universe")
      group_a = create_list(:image, 3, universe: universe)
      group_b = create_list(:image, 2, universe: universe)

      group_a.each { |img| img.image_file.blob.update!(checksum: "AAAAAAAAAAAAAAAAAAAAAA==") }
      group_b.each { |img| img.image_file.blob.update!(checksum: "BBBBBBBBBBBBBBBBBBBBBB==") }
      [*group_a, *group_b].each_with_index { |img, i| img.update!(created_at: (10 - i).days.ago) }

      expect do
        post admin_dedupe_images_dedupe_universe_path, params: { universe_id: universe.id }
      end.to change { Image.where(universe_id: universe.id).count }.by(-3)

      expect(Image.exists?(group_a.first.id)).to be(true)
      expect(Image.where(id: group_a[1..].map(&:id))).to be_empty
      expect(Image.exists?(group_b.first.id)).to be(true)
      expect(Image.exists?(group_b.last.id)).to be(false)
    end
  end

  describe "POST dedupe_group" do
    it "shows an error when the group has no images" do
      post admin_dedupe_images_dedupe_group_path, params: {
        universe_id: universe.id, checksum: "does-not-exist", byte_size: 123, content_type: "image/jpeg"
      }

      expect(response).to redirect_to(admin_dedupe_images_url)
      expect(flash[:error]).to include("No images found")
    end

    it "keeps the earliest image and deletes the rest" do
      earliest = create(:image, universe: universe)
      later = create(:image, universe: universe)
      earliest.update!(created_at: 2.days.ago)
      later.update!(created_at: 1.day.ago)
      blob = earliest.image_file.blob

      expect do
        post admin_dedupe_images_dedupe_group_path, params: {
          universe_id: universe.id, checksum: blob.checksum, byte_size: blob.byte_size, content_type: blob.content_type
        }
      end.to change(Image, :count).by(-1)

      expect(Image.exists?(earliest.id)).to be(true)
      expect(Image.exists?(later.id)).to be(false)
    end
  end
end
