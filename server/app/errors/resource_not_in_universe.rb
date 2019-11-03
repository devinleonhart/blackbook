# frozen_string_literal: true

class ResourceNotInUniverse < BlackBookError
  def initialize(resource_name, resource_id, universe_id)
    message = <<~ERROR_MESSAGE.squish
      #{resource_name.capitalize} with ID #{resource_id} does not belong to
      Universe #{universe_id}.
    ERROR_MESSAGE

    super(message)
  end

  def status
    :bad_request
  end
end
