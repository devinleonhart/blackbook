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
end
