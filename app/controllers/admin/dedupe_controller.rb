# frozen_string_literal: true

module Admin
  class DedupeController < ApplicationController
    before_action :require_admin!

    def images
      duplicate_groups =
        Image
          .joins(image_file_attachment: :blob)
          .select(
            "images.universe_id AS universe_id, " \
            "active_storage_blobs.checksum AS checksum, " \
            "active_storage_blobs.byte_size AS byte_size, " \
            "active_storage_blobs.content_type AS content_type, " \
            "COUNT(*) AS images_count",
          )
          .group(
            "images.universe_id",
            "active_storage_blobs.checksum",
            "active_storage_blobs.byte_size",
            "active_storage_blobs.content_type",
          )
          .having("COUNT(*) > 1")
          .order(Arel.sql("images_count DESC"))
          .limit(200)

      universe_ids = duplicate_groups.map(&:universe_id).uniq
      universes_by_id = Universe.where(id: universe_ids).index_by(&:id)

      grouped =
        duplicate_groups
          .group_by(&:universe_id)
          .map do |universe_id, groups_for_universe|
            universe = universes_by_id[universe_id]
            next if universe.nil?

            groups =
              groups_for_universe.map do |row|
                images =
                  Image
                    .includes(:universe)
                    .joins(image_file_attachment: :blob)
                    .where(
                      universe_id: universe_id,
                      active_storage_blobs: {
                        checksum: row.checksum,
                        byte_size: row.byte_size,
                        content_type: row.content_type,
                      },
                    )
                    .order(created_at: :asc)

                {
                  checksum: row.checksum,
                  byte_size: row.byte_size.to_i,
                  content_type: row.content_type,
                  count: row.images_count.to_i,
                  images: images,
                }
              end

            {
              universe: universe,
              groups: groups.sort_by { |g| -g[:count] },
            }
          end
          .compact

      @universes_with_duplicate_images =
        grouped.sort_by { |entry| entry[:universe].name.to_s.downcase }
    end

    def dedupe_group
      universe_id = params[:universe_id].to_i
      checksum = params[:checksum].to_s
      byte_size = params[:byte_size].to_i
      content_type = params[:content_type].to_s

      images =
        Image
          .joins(image_file_attachment: :blob)
          .where(
            universe_id: universe_id,
            active_storage_blobs: { checksum: checksum, byte_size: byte_size, content_type: content_type },
          )
          .order(created_at: :asc)

      keep = images.first
      if keep.nil?
        flash[:error] = "No images found for that dedupe group."
        redirect_to admin_dedupe_images_url
        return
      end

      deleted = 0
      Image.where(id: images.offset(1).pluck(:id)).find_each do |image|
        image.destroy!
        deleted += 1
      end

      flash[:success] = "Kept image ##{keep.id} and deleted #{deleted} duplicate#{deleted == 1 ? '' : 's'}."
      redirect_to admin_dedupe_images_url
    end
  end
end
