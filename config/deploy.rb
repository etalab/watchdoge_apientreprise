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

set :commit, ENV['commit']
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
    else
      raise 'to need to be set, default should be sandbox'
    end
  end

set :branch, branch
ensure!(:branch)

task :samhain_db_update do
  command %{sudo /usr/local/sbin/update-samhain-db.sh "#{fetch(:deploy_to)}"}
end

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
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/pids/")
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/log/")
  invoke :'ownership'
  invoke :'samhain_db_update'
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
    set :bundle_options, fetch(:bundle_options) + ' --clean'
    invoke :'bundle:install'
    invoke :'rails:db_migrate' # Database must exists here ;)
    invoke :'deploy:cleanup'
    invoke :'ownership'

    on :launch do
      in_path(fetch(:current_path)) do
        command %(mkdir -p tmp/)
        command %(touch tmp/restart.txt)

        invoke :refill_database

        if ENV['to'] == 'production'
          invoke :sidekiq
          comment 'Updating cronotab'.green
          invoke :'whenever:update'
        end
        invoke :'ownership'

        invoke :passenger
      end
    end
  end
  invoke :'samhain_db_update'
  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task refill_database: :remote_environment do
  comment 'Refill Endpoints table'.yellow
  command "/usr/local/rbenv/shims/bundle exec rake refill_database RAILS_ENV=#{ENV['to']}"
end

task :sidekiq do
  comment 'Restarting Sidekiq (reloads code)'.green
  command %(sudo systemctl restart sidekiq_watchdoge_#{ENV['to']}_1)
end

task :passenger do
  comment 'Attempting to start Passenger app'.green
  command %{
    if (sudo passenger-status | grep watchdoge_#{ENV['to']}) >/dev/null
    then
      sudo passenger-config restart-app /var/www/watchdoge_#{ENV['to']}/current
    else
      echo 'Skipping: no passenger app found (will be automatically loaded)'
    fi
  }
end

task :ownership do
  command %{sudo chown -R deploy "#{fetch(:deploy_to)}"}
end
