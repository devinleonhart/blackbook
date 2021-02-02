# frozen_string_literal: true

class InvalidCharacterIdForRelationship < BlackBookError
  def initialize(mutual_relationship_id, character_id)
    super(<<~MESSAGE.squish)
      No character with ID #{character_id} is associated with the relationship
      with ID #{mutual_relationship_id}.
    MESSAGE
  end

  def status
    :bad_request
  end
end
