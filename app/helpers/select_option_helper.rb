module SelectOptionHelper
  def generate_character_names(characters, existing_tags)
    names = Array.new
    characters.each do | character |
      unless existing_tags.any? { | tag | tag.character.id == character.id }
       names.push([character.name, character.id])
      end
    end
    return names
  end

  def generate_collaborator_names(users, existing_collaborators)
    names = Array.new
    users.each do | user |
      unless existing_collaborators.any? { | collaborator | collaborator.id == user.id }
       names.push([user.display_name, user.id])
      end
    end
    return names
  end
end
