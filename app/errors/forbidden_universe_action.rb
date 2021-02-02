# frozen_string_literal: true

class ForbiddenUniverseAction < BlackBookError
  def initialize(verb, collaborators_allowed)
    message = if collaborators_allowed
      "A universe can only be #{verb} by its owner or collaborators."
    else
      "A universe can only be #{verb} by its owner."
    end
    super(message)
  end

  def status
    :forbidden
  end
end
