require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'colorize'

ENV['domain'] || raise('no domain provided'.red)
ENV['to'] ||= 'sandbox'
%w[development sandbox staging production].include?(ENV['to']) || raise("target environment (#{ENV['to']}) not in the list")

print "Deploy to #{ENV['to']}\n".green

set :user, 'deploy' if ENV['domain'] != 'localhost'
set :application_name, 'watchdoge'
set :domain, ENV['domain']
set :deploy_to, "/var/www/watchdoge_#{ENV['to']}"
set :rails_env, ENV['to']
set :forward_agent, true
set :repository, 'git@github.com:etalab/watchdoge_apientreprise.git'
# set :repository, './'

branch =
  begin
    case ENV['to']
    when 'production'
      'master'
    when 'staging'
      'staging'
    when 'development', 'sandbox'
      'develop'
    end
  end

set :branch, branch
ensure!(:branch)

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push(
  'log',
  'bin',
  'config/environments',
  'tmp/pids',
  'tmp/cache'
)

set :shared_files, fetch(:shared_files, []).push(
  'config/database.yml',
  'config/watchdoge_secrets.yml'
)

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  if ENV['domain'] != 'localhost'
    # Be sure to commit your .ruby-version or .rbenv-version to your repository.
    # TODO ansible: rbenv !
    #  invoke :'rbenv:load'
  else
    invoke :'rvm:use', '2.4.0@watchdoge'
  end
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # Production database has to be setup !
  # command %(rbenv install 2.3.0)
end

desc 'Deploys the current version to the server.'
task deploy: :environment do
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
        command %(touch tmp/status.json)

        # Crono has to:
        # - be in 'launch' if not Mina kill remaing processes
        # - run in current_path to access bundle
        # - re-run rvm:use after 'cd' command
        invoke :crono
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task crono: :environment do
  command %(bundle exec crono restart -N watchdoge-crono-#{ENV['to']} -e #{ENV['to']})
end
