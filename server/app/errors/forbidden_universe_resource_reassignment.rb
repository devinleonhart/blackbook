# frozen_string_literal: true

# This exception class represents an attempt to assign a resource that is
# nested to a Universe to a universe that the user doesn't have access to.
class ForbiddenUniverseResourceReassignment < BlackBookError
  def initialize(new_universe_id, model_name)
    super(<<~MESSAGE.squish)
      You do not have access to the universe with ID #{new_universe_id}, which
      is required in order to move this #{model_name} into that universe.
    MESSAGE
  end

  def status
    :forbidden
  end
end
