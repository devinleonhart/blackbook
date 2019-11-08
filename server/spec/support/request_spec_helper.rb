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
  # This provides the url_for helper, but using url_for() raises the error
  # "Missing host to link to! Please provide the :host parameter, set
  # default_url_options[:host], or set :only_path to true"
  # This appears to be an error between Rails and Rspec has no resolution:
  # https://github.com/rspec/rspec-rails/issues/1275
  # config.include Rails.application.routes.url_helpers

  config.include JsonResponseHelper, type: :controller
end

RSpec.shared_examples "returns a success HTTP status code" do
  it "returns a success HTTP status code" do
    expect(response).to have_http_status(:success)
  end
end
