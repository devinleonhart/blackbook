# frozen_string_literal: true

module JsonResponseHelper
  # returns valid authentication headers for the given User model
  def auth_headers_for(user)
    user.create_new_auth_token
  end

  # authenticates the user for the next request
  def authenticate(user)
    @request.headers.merge!(auth_headers_for(user))
  end

  # parse a JSON response into a Ruby hash
  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include JsonResponseHelper, type: :controller
end
