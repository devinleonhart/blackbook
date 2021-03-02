# frozen_string_literal: true

# Load DSL and Setup Up Stages
require "capistrano/setup"
require "capistrano/deploy"

require "capistrano/rails"
require "capistrano/bundler"
require "capistrano/rbenv"

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require "capistrano/puma"
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Daemon

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
