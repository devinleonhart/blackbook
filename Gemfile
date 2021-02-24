source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>=3.0.0'

gem 'rails', '~> 6.1.2.1'
gem 'pg'
gem 'puma'
gem 'irb'
gem 'jbuilder'
gem 'bootsnap'
gem 'factory_bot_rails'
gem 'rack-cors'
gem 'pg_search'
gem 'discard'
gem 'devise'
gem 'webpacker'
gem "view_component", require: "view_component/engine"
gem 'stimulus-rails'
gem 'image_processing'
gem 'securerandom'
gem 'will_paginate'

group :development, :test do
  gem 'awesome_print'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rails'
  gem 'pry-rails', :group => :development
end

group :development do
  gem 'annotate'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano3-puma'
end

group :test do
  gem 'shoulda-matchers'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
