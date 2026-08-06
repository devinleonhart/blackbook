# frozen_string_literal: true

# Shared helpers and setup for request specs.
module RequestHelpers
  # A primary key that is guaranteed not to exist, for exercising
  # not-found branches.
  def missing_id
    999_999
  end
end

# Common baseline: a signed-in user who owns a universe.
# Specs that need collaborators/strangers add their own `let`s on top.
RSpec.shared_context "with a signed-in owner" do
  let(:owner) { create(:user) }
  let(:universe) { create(:universe, owner: owner) }

  before { sign_in(owner) }
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
