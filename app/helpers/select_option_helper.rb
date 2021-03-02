# frozen_string_literal: true

module SelectOptionHelper
  def generate_character_names(characters, existing_tags)
    names = []
    characters.each do |character|
      names.push([character.name, character.id]) unless existing_tags.any? { |tag| tag.character.id == character.id }
    end
    names
  end

  def generate_collaborator_names(users, existing_collaborators)
    names = []
    users.each do |user|
      next if existing_collaborators.any? do |collaborator|
                collaborator.id == user.id
              end

      names.push([user.display_name, user.id])
    end
    names
  end
end
