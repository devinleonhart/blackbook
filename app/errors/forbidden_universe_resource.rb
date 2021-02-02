# frozen_string_literal: true

class ForbiddenUniverseResource < BlackBookError
  def initialize(universe_id, model_name)
    super(<<~MESSAGE.squish)
      You must be an owner or collaborator for the universe with ID
      #{universe_id} to interact with its #{model_name.pluralize}.
    MESSAGE
  end

  def status
    :forbidden
  end
end
