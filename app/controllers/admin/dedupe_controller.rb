# frozen_string_literal: true

module Admin
  class DedupeController < ApplicationController
    before_action :require_admin!

    def images
      @universes_with_duplicate_images = ImageDeduplicator.duplicate_groups_by_universe
    end

    def dedupe_group
      result = ImageDeduplicator.dedupe_group(
        universe_id: params[:universe_id].to_i,
        checksum: params[:checksum].to_s,
        byte_size: params[:byte_size].to_i,
        content_type: params[:content_type].to_s
      )

      if result.nil?
        flash[:error] = "No images found for that dedupe group."
      else
        keep, deleted = result
        flash[:success] = "Kept image ##{keep.id} and deleted #{helpers.pluralize(deleted, 'duplicate')}."
      end

      redirect_to admin_dedupe_images_url
    end

    def dedupe_universe
      universe = Universe.find_by(id: params[:universe_id].to_i)

      if universe.nil?
        flash[:error] = "Universe not found."
        return redirect_to admin_dedupe_images_url
      end

      deleted, groups_processed = ImageDeduplicator.dedupe_universe(universe)
      flash[:success] = dedupe_universe_message(universe, deleted, groups_processed)

      redirect_to admin_dedupe_images_url
    end

    private

    def dedupe_universe_message(universe, deleted, groups_processed)
      return "No duplicate image uploads found for #{universe.name}." if groups_processed.zero?

      "For #{universe.name}, kept 1 image per group and deleted #{helpers.pluralize(deleted, 'duplicate')} " \
        "across #{helpers.pluralize(groups_processed, 'group')}."
    end
  end
end
