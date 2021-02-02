require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/puma'

set :application_name, 'blackbook'
set :domain, '198.199.119.91'
set :deploy_to, '/home/blackbook'
set :repository, 'https://github.com/devinleonhart/blackbook'
set :branch, 'master'

# Optional settings:
   set :user, 'blackbook'  # Username in the server to SSH to.
   set :port, '22'               # SSH port number.
#   set :forward_agent, true       # SSH forward_agent.

set :shared_dirs,
  ['log', 'tmp/pids', 'tmp/sockets', 'storage']


# mina-puma settings
set :puma_config,    "config/puma.rb"
set :puma_socket,    "#{fetch(:shared_path)}/tmp/sockets/puma.sock"
set :puma_state,     "#{fetch(:shared_path)}/tmp/sockets/puma.state"
set :puma_pid,       "#{fetch(:shared_path)}/tmp/pids/puma.pid"
set :puma_stdout,    "#{fetch(:shared_path)}/log/puma.log"
set :puma_stderr,    "#{fetch(:shared_path)}/log/puma.log"
set :pumactl_socket, "#{fetch(:shared_path)}/tmp/sockets/pumactl.sock"
set :puma_root_path, "#{fetch(:current_path)}"

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

task :remote_environment do
  invoke :'rbenv:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0 --skip-existing}
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  #invoke :'git:ensure_pushed'

  command %{LANG=en.US-UTF-8}

  deploy do
    # load environment variables
    command %{source ~/.bashrc}

    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    command %{ln -rs /home/blackbook/master.key config/}
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'puma:stop'
      command %{rm -f tmp/sockets/*}
      invoke :'puma:start'
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
