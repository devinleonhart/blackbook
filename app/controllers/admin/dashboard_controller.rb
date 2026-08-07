# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    before_action :require_admin!

    def index
      @stats = {
        users: User.count,
        universes: Universe.count,
        characters: Character.count,
        images: Image.count,
        storage: ActiveStorage::Blob.sum(:byte_size),
        duplicate_groups: ImageDeduplicator.duplicate_group_count
      }
    end
  end
end
