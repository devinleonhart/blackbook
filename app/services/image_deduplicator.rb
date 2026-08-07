# frozen_string_literal: true

# Finds and removes duplicate image uploads within a universe. Two images are
# duplicates when their attached blobs are identical (same checksum, byte_size
# and content_type). The earliest-created image of each group is always kept.
#
# All query/deletion logic lives here; Admin::DedupeController just calls these
# and renders flash/redirect.
class ImageDeduplicator
  class << self
    # Read side: per-universe listing of duplicate groups for the admin view.
    # Returns [{ universe:, groups: [{ checksum:, byte_size:, content_type:,
    # count:, images: }] }], sorted by universe name.
    def duplicate_groups_by_universe
      groups = duplicate_group_rows(limit: 200)
      images_by_key = images_for_groups(groups)
      universes_by_id = Universe.where(id: groups.map(&:universe_id).uniq).index_by(&:id)

      entries = groups.group_by(&:universe_id).filter_map do |universe_id, rows|
        universe = universes_by_id[universe_id]
        next unless universe

        { universe: universe, groups: build_groups(rows, images_by_key) }
      end

      entries.sort_by { |entry| entry[:universe].name.to_s.downcase }
    end

    # Delete side: dedupe a single group. Returns [kept_image, deleted_count],
    # or nil if the group has no images.
    def dedupe_group(universe_id:, checksum:, byte_size:, content_type:)
      images =
        Image
        .joins(image_file_attachment: :blob)
        .where(
          universe_id: universe_id,
          active_storage_blobs: { checksum: checksum, byte_size: byte_size, content_type: content_type }
        )
        .order(created_at: :asc)

      keep = images.first
      return nil if keep.nil?

      [keep, destroy_images(images.offset(1).pluck(:id))]
    end

    # Delete side: dedupe every group in a universe. Returns
    # [deleted_count, groups_processed].
    def dedupe_universe(universe)
      groups = duplicate_group_rows(universe_id: universe.id)
      images_by_key = images_for_groups(groups)

      deleted = 0
      groups_processed = 0

      groups.each do |row|
        images = images_by_key.fetch(key_for(row.universe_id, row.checksum, row.byte_size, row.content_type), [])
        next if images.empty?

        groups_processed += 1
        # images are ordered created_at asc, so drop(1) keeps the earliest.
        deleted += destroy_images(images.drop(1).map(&:id))
      end

      [deleted, groups_processed]
    end

    # Number of duplicate groups across all universes — a single grouped query,
    # no image records loaded. Used for the admin dashboard stat.
    def duplicate_group_count
      duplicate_group_rows.length
    end

    private

    # Duplicate groups (COUNT > 1) keyed by universe + blob identity. `limit`
    # caps the listing; the per-universe dedupe passes none so it processes all.
    def duplicate_group_rows(universe_id: nil, limit: nil)
      scope = Image.joins(image_file_attachment: :blob)
      scope = scope.where(universe_id: universe_id) if universe_id

      scope = scope
              .select(
                "images.universe_id AS universe_id, " \
                "active_storage_blobs.checksum AS checksum, " \
                "active_storage_blobs.byte_size AS byte_size, " \
                "active_storage_blobs.content_type AS content_type, " \
                "COUNT(*) AS images_count"
              )
              .group(
                "images.universe_id",
                "active_storage_blobs.checksum",
                "active_storage_blobs.byte_size",
                "active_storage_blobs.content_type"
              )
              .having("COUNT(*) > 1")

      limit ? scope.order(Arel.sql("images_count DESC")).limit(limit) : scope
    end

    # Loads every image belonging to any of the given groups in ONE query and
    # indexes them by group key, so callers avoid a per-group query.
    def images_for_groups(groups)
      return {} if groups.empty?

      Image
        .includes(:universe)
        .joins(image_file_attachment: :blob)
        .where(
          universe_id: groups.map(&:universe_id).uniq,
          active_storage_blobs: { checksum: groups.map(&:checksum).uniq }
        )
        .order(created_at: :asc)
        .preload(image_file_attachment: :blob)
        .group_by do |image|
          blob = image.image_file.blob
          key_for(image.universe_id, blob.checksum, blob.byte_size, blob.content_type)
        end
    end

    def build_groups(rows, images_by_key)
      rows
        .map { |row| build_group(row, images_by_key) }
        .sort_by { |group| -group[:count] }
    end

    def build_group(row, images_by_key)
      key = key_for(row.universe_id, row.checksum, row.byte_size, row.content_type)
      {
        checksum: row.checksum,
        byte_size: row.byte_size.to_i,
        content_type: row.content_type,
        count: row.images_count.to_i,
        images: images_by_key.fetch(key, [])
      }
    end

    # A stable, type-normalized key so SQL group rows and loaded Image records
    # land in the same bucket regardless of how the DB types the raw columns.
    def key_for(universe_id, checksum, byte_size, content_type)
      [universe_id.to_i, checksum.to_s, byte_size.to_i, content_type.to_s]
    end

    def destroy_images(image_ids)
      count = 0
      Image.where(id: image_ids).find_each do |image|
        image.destroy!
        count += 1
      end
      count
    end
  end
end
