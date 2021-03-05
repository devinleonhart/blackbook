# frozen_string_literal: true

module SelectOptionHelper
  def generate_character_names(characters, existing_tags)
    names = []
    characters.each do |character|
      names.push([character.name, character.id]) unless existing_tags.any? { |tag| tag.character.id == character.id }
    end
    names
  end

  def generate_collaborator_names(users, existing_collaborators, owner)
    names = []
    users.each do |user|
      next if existing_collaborators.any? do |collaborator|
        collaborator.id == user.id
      end

      next if user.id == owner.id

      names.push([user.display_name, user.id])
    end
    names
  end

    def generate_relationship_names(characters, existing_characters)
      names = []
      characters.each do |character|
        names.push([character.name, character.id]) unless existing_characters.any? { |echaracter| echaracter.id == character.id }
      end
      names
    end
end
