require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/rbenv'
require 'mina/whenever'
require 'colorize'

ENV['domain'] ||= 'watchdoge.entreprise.api.gouv.fr'
ENV['to'] ||= 'sandbox'
%w[sandbox production].include?(ENV['to']) || raise("target environment (#{ENV['to']}) not in the list")

comment "Deploy to #{ENV['to']}\n".green

set :user, 'deploy' if ENV['domain'] != 'localhost'
set :application_name, 'watchdoge'
set :domain, ENV['domain']

set :deploy_to, "/var/www/watchdoge_#{ENV['to']}"
set :rails_env, ENV['to']

set :forward_agent, true
set :port, 22
set :repository, 'git@github.com:etalab/watchdoge_apientreprise.git'

branch = ENV['branch'] ||
  begin
    case ENV['to']
    when 'production'
      'master'
    when 'development', 'sandbox'
      'develop'
    end
  end

set :branch, branch
ensure!(:branch)

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push(
  'bin',
  'config/environments',
  'log',
  'tmp/pids',
  'tmp/cache'
)

set :shared_files, fetch(:shared_files, []).push(
  'config/database.yml',
  'config/secrets.yml'
)

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  if ENV['domain'] != 'localhost'
    # Be sure to commit your .ruby-version or .rbenv-version to your repository.
    set :rbenv_path, '/usr/local/rbenv'
    invoke :'rbenv:load'
  else
    invoke :'rvm:use', '2.4.2@watchdoge'
  end
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task setup: :remote_environment do
  # Production database has to be setup !
  # command %(rbenv install 2.3.0)
end

desc 'Deploys the current version to the server.'
task deploy: :remote_environment do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate' # Database must exists here ;)
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %(mkdir -p tmp/)
        command %(touch tmp/restart.txt)

        if ENV['to'] == 'production'
          comment 'Updating cronotab'.green
          invoke :'whenever:update'
        else
          invoke :mono_ping
        end

        invoke :passenger
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task mono_ping: :remote_environment do
  comment 'One Ping Attempt'.yellow
  command "/usr/local/rbenv/shims/bundle exec rake watch:all RAILS_ENV=#{ENV['to']}"
end

task :passenger do
  comment 'Attempting to start Passenger app'.green
  command %{
    if (sudo passenger-status | grep watchdoge_#{ENV['to']}) >/dev/null
    then
      passenger-config restart-app /var/www/watchdoge_#{ENV['to']}/current
    else
      echo 'Skipping: no passenger app found (will be automatically loaded)'
    fi
  }
end
