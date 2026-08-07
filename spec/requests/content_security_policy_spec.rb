# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Content Security Policy", type: :request do
  def csp_nonce
    response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]
  end

  it "sets a script-src nonce" do
    get new_user_session_path

    expect(response.headers["Content-Security-Policy"]).to include("script-src 'self' 'nonce-")
    expect(csp_nonce).to be_present
  end

  # Turbo re-evaluates a fetched page's inline importmap <script> against the
  # original document's CSP header, so the nonce must stay stable across a
  # session; a per-request random nonce would cause script-src-elem violations.
  it "reuses the same nonce across requests in one session" do
    get new_user_session_path
    first = csp_nonce

    get new_user_session_path
    second = csp_nonce

    expect(second).to eq(first)
  end
end
