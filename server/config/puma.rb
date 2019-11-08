# frozen_string_literal: true

rails_env = ENV.fetch("RAILS_ENV") { "development" }
environment rails_env

if rails_env == "production"
  # number of worker processes (set to 2 or greater to allow phased restarts)
  workers 1

  # Min and Max threads per worker
  threads 1, 6

  app_dir = File.expand_path("../..", __FILE__)
  log_dir = "#{app_dir}/log"
  tmp_dir = "#{app_dir}/tmp"

  # Default to production
  rails_env = ENV['RAILS_ENV'] || "production"
  environment rails_env

  stdout_redirect "#{log_dir}/puma.stdout.log", "#{log_dir}/puma.stderr.log", true
  bind "unix://#{tmp_dir}/sockets/puma.sock"
  pidfile "#{tmp_dir}/pids/puma.pid"
  state_path "#{tmp_dir}/pids/puma.state"
  daemonize
  activate_control_app "unix://#{tmp_dir}/sockets/pumactl.sock"

  on_worker_boot do
    require "active_record"
    ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
    ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
  end
else
  workers 1
  threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
  threads threads_count, threads_count
  port        ENV.fetch("PORT") { 3000 }
  plugin :tmp_restart
end
