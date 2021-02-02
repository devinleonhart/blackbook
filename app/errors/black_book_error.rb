# frozen_string_literal: true

class BlackBookError < StandardError
  def status
    :internal_server_error
  end
end
