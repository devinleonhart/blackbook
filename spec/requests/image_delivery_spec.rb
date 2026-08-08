# frozen_string_literal: true

require "rails_helper"

# Active Storage runs in proxy mode (see config/application.rb) so image URLs are
# stable and cacheable rather than short-lived redirects. This guards against a
# regression to redirect mode, which caused broken images on mobile Safari during
# rapid Turbo navigation.
RSpec.describe "Image delivery", type: :request do
  include_context "with a signed-in owner"

  it "renders grid thumbnails as stable proxy URLs, not expiring redirects" do
    create(:image, universe: universe)

    get universe_path(universe)

    expect(response.body).to include("/rails/active_storage/representations/proxy/")
    expect(response.body).not_to include("/rails/active_storage/representations/redirect/")
  end

  it "streams a variant through the proxy with long-lived public caching" do
    create(:image, universe: universe)
    get universe_path(universe)
    proxy_url = response.body[%r{/rails/active_storage/representations/proxy/[^"]+}]
    expect(proxy_url).to be_present

    get proxy_url

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to start_with("image/")
    expect(response.headers["Cache-Control"]).to include("public")
  end
end
