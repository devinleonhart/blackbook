# frozen_string_literal: true

module JsonResponseHelper
  # parse a JSON response into a Ruby hash
  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include JsonResponseHelper, type: :controller
end
