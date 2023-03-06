source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.1'

gem 'rails', '~> 7.0.2', '>= 7.0.2.2'

gem 'aws-sdk-s3', '~> 1.119', '>= 1.119.1'
gem 'bootsnap', require: false
gem 'bulma-rails', '~> 0.9.2'
gem 'devise', '~> 4.7', '>= 4.7.3'
gem 'factory_bot_rails', '~> 6.1'
gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.8'
gem 'image_processing', '~> 1.2'
gem 'importmap-rails'
gem 'jbuilder'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'sassc-rails'
gem 'securerandom', '~> 0.1.0'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]
gem 'will_paginate', '~> 3.3'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'pry', '~> 0.14.1'
  gem 'rubocop-rails', '~> 2.9', '>= 2.9.1'
  gem 'rubocop-rspec', '~> 2.2'
end

group :development do
  gem 'annotate', '~> 3.2'
  gem 'solargraph'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner', '~> 2.0', '>= 2.0.1'
  gem 'rspec-rails', '~> 4.0.2'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
