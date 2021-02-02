# frozen_string_literal: true

class MissingResource < BlackBookError
  def initialize(model_name, id)
    message = "No #{model_name} with ID #{id} exists."
    super(message)
  end

  def status
    :not_found
  end
end
