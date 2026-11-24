# frozen_string_literal: true

module BlackbookMcp
  module ImageTools
    extend ToolSet

    PARTS = [:characters, { image_file_attachment: :blob }].freeze

    def self.present(image, access)
      Present.images([image], access.user).first
    end

    def self.page(scope, input, access)
      Page.of(scope.includes(*PARTS).order(created_at: :desc, id: :desc), input) do |list|
        Present.images(list, access.user)
      end
    end

    # Any unknown character refuses the whole request.
    def self.characters_of(image, ids)
      found = image.universe.characters.where(id: ids)
      raise Refused, "Character not found" if found.size < ids.uniq.size

      found
    end

    tool("list_images", :read, "List images, newest first, optionally of one universe or character, untagged, or " \
                               "your favorites. Gives addresses, not image data. Paged, 50 at a time",
         { universe_id: id, character_id: id, untagged: flag, favorites: flag, **paging },
         required: []) do |input, access|
      scope = access.images
      scope = access.universe(input[:universe_id]).images if input[:universe_id]
      if input[:character_id]
        scope = scope.where(id: access.character(input[:character_id]).appearances.select(:image_id))
      end
      scope = scope.where(id: Image.untagged.select(:id)) if input[:untagged]
      scope = scope.where(id: access.user.image_favorites.select(:image_id)) if input[:favorites]
      page(scope, input, access)
    end

    tool("get_image", :read, "Get an image's characters, facts and address", { id: id }) do |input, access|
      present(access.image(input[:id]), access)
    end

    tool("list_favorites", :read, "List your favorite images, newest first. Paged, 50 at a time",
         paging, required: []) do |input, access|
      page(access.images.where(id: access.user.image_favorites.select(:image_id)), input, access)
    end

    tool("tag_image", :write, "Mark characters of the image's universe as appearing in an image",
         { image_id: id, character_ids: { type: "array", items: id, minItems: 1, maxItems: 100 } }) do |input, access|
      image = access.image(input[:image_id])
      image.tag_characters(characters_of(image, input[:character_ids]).ids)
      present(image.reload, access)
    end

    tool("favorite_image", :write, "Make an image one of your favorites", { image_id: id }) do |input, access|
      image = access.image(input[:image_id])
      image.favorite_by(access.user)
      present(image, access)
    end

    tool("unfavorite_image", :write, "Remove an image from your favorites", { image_id: id }) do |input, access|
      image = access.image(input[:image_id])
      image.unfavorite_by(access.user)
      present(image, access)
    end

    tool("untag_image", :delete, "Remove a character from an image. Both remain",
         { image_id: id, character_id: id }) do |input, access|
      image = access.image(input[:image_id])
      appearance = image.appearances.find_by(character_id: input[:character_id])
      raise Refused, "Character not found" if appearance.nil?

      appearance.destroy!
      present(image.reload, access)
    end
  end
end
