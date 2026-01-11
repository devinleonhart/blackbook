# This file is copied to spec/ when you run 'rails generate rspec:install'

require "simplecov"

SimpleCov.start "rails" do
  add_filter "/spec/"
  enable_coverage :branch

  # Keep reports stable for CI/Docker
  track_files "{app,lib}/**/*.rb"
end

ENV["RAILS_ENV"] = "test" if ENV["RAILS_ENV"].to_s != "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "spec_helper"
require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!
Rails.application.reload_routes!
Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => error
  puts error.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [Rails.root.join("spec/fixtures").to_s]
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
end
