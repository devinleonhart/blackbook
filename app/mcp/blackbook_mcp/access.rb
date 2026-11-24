# frozen_string_literal: true

module BlackbookMcp
  # The records that a user owns or collaborates on. Being an admin gives nothing here.
  class Access
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def universes
      Universe.where(id: Universe.accessible_to(user).reselect(:id))
    end

    def characters
      Character.where(universe_id: universes.select(:id))
    end

    def images
      Image.where(universe_id: universes.select(:id))
    end

    def traits
      Trait.where(character_id: characters.select(:id))
    end

    def universe(id) = find(universes, id)
    def character(id) = find(characters, id)
    def image(id) = find(images, id)
    def trait(id) = find(traits, id)

    private

    def find(scope, id)
      scope.find_by(id: id) || raise(Refused, "#{scope.model_name.human} not found")
    end
  end
end
