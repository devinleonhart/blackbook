# frozen_string_literal: true

module BlackbookMcp
  # The data of records, with the counts of several in one query each.
  module Present
    module_function

    def universes(list, user)
      ids = list.map(&:id)
      characters = Character.where(universe_id: ids).group(:universe_id).count
      images = Image.where(universe_id: ids).group(:universe_id).count
      list.map do |universe|
        { id: universe.id, name: universe.name, owner: universe.owner.display_name,
          role: universe.owner_id == user.id ? "owner" : "collaborator",
          characters: characters.fetch(universe.id, 0), images: images.fetch(universe.id, 0) }
      end
    end

    def trait_counts(universe)
      counts = Trait.joins(:character).where(characters: { universe_id: universe.id }).group(:name).count
      counts.sort_by { |name, count| [-count, name] }.map { |name, count| { name: name, characters: count } }
    end

    def characters(list)
      images = Appearance.where(character_id: list.map(&:id)).group(:character_id).count
      list.map do |character|
        { id: character.id, universe_id: character.universe_id, name: character.name,
          traits: character.traits.map(&:name).sort, images: images.fetch(character.id, 0) }
      end
    end

    def character(record)
      characters([record]).first.merge(traits: record.traits.sort_by(&:name).map { |trait| trait.slice(:id, :name) })
    end

    def trait(record)
      record.slice(:id, :character_id, :name)
    end

    def images(list, user)
      favorites = user.image_favorites.where(image_id: list.map(&:id)).pluck(:image_id).to_set
      list.map { |image| image_fields(image).merge(favorited: favorites.include?(image.id)) }
    end

    # The address and facts of the file, never its data.
    def image_fields(image)
      blob = image.image_file.blob
      { id: image.id, universe_id: image.universe_id,
        characters: image.characters.sort_by { |character| character.name.downcase }.map { |c| c.slice(:id, :name) },
        content_type: blob.content_type, byte_size: blob.byte_size, created_at: image.created_at.utc.iso8601,
        url: routes.view_image_url(id: image.id, filename: blob.filename.to_s, **site),
        page: routes.edit_universe_image_url(image.universe_id, image.id, **site) }
    end

    def routes
      Rails.application.routes.url_helpers
    end

    def site
      Rails.configuration.x.site
    end
  end
end
