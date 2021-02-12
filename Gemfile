source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>=2.7.2'

gem 'rails', '~> 6.1.2.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'irb'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'factory_bot_rails', '~> 5.0.2'
gem 'rack-cors'
gem 'pg_search', '~> 2.3.0'
gem 'discard', '~> 1.1.0'
gem 'devise'
gem 'webpacker', '~> 6.0.0.beta.4'

group :development, :test do
  gem 'awesome_print', '~> 1.8.0'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8.0'
  gem 'rubocop-rspec'
  gem 'rubocop-rails'
end

group :development do
  gem 'annotate', '~> 2.7.5'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'mina', '~> 1.2.3'
  gem 'mina-puma', '~> 1.1.0', require: false
end

group :test do
  gem 'shoulda-matchers', '~> 4.1.2'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
