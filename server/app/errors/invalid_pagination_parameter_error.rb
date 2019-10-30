# frozen_string_literal: true

class InvalidPaginationParameterError < BlackBookError
  def initialize(parameter_name, value, reason)
    super(<<~ERROR_MESSAGE.squish)
      Invalid #{parameter_name} parameter value: #{value}. #{reason}
    ERROR_MESSAGE
  end

  def status
    :bad_request
  end
end

