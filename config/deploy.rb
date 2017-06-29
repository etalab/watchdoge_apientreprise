require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

ENV['domain'] || raise('no domain provided')
ENV['to'] ||= 'development'

print "Deploy to #{ENV['to']}\n"

set :application_name, 'watchdoge'
set :domain, ENV['domain']
set :deploy_to, '/var/www/watchdoge'
set :rails_env, ENV['to']
set :repository, 'git@github.com:etalab/watchdoge_apientreprise.git'
#set :repository, './'

branch =
  begin
    case ENV['to']
    when 'production'
      'master'
    when 'staging'
      'staging'
    when 'development'
      'develop'
    end
  end

set :branch, branch
ensure!(:branch)

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push(
  'log',
  'bin',
  'tmp/pids',
  'tmp/cache'
)

set :shared_files, fetch(:shared_files, []).push(
  'db/development.sqlite3',
  'db/production.sqlite3'
)

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'
  invoke :'rvm:use', '2.4.0@watchdoge'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # Production database has to be setup !
  # command %{rbenv install 2.3.0}
  command %{mkdir -p "#{fetch(:deploy_to)}/shared/log"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/log"}

  command %{mkdir -p "#{fetch(:deploy_to)}/shared/bin"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/bin"}

  command %{mkdir -p "#{fetch(:deploy_to)}/shared/tmp/pids"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/tmp/pids"}

  command %{mkdir -p "#{fetch(:deploy_to)}/shared/tmp/cache"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/tmp/cache"}

  command %{mkdir -p "#{fetch(:deploy_to)}/shared/db"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/db"}
end

desc "Deploys the current version to the server."
task :deploy => :environment do
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
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}

        # Crono has to:
        # - be in 'launch' if not Mina kill remaing processes
        # - run in current_path to access bundle
        # - re-run rvm:use after 'cd' command
        invoke :'crono'
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task :crono => :environment do
   command %{./bin/bundle exec crono restart -N watchdoge-crono -e #{ENV['to']}}
end
