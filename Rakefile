# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

domain = 'watchdoge.entreprise.api.gouv.fr'

task :deploy_server do
  sh "bundle exec mina deploy domain=#{domain}"
end

task :setup_server do
  sh "bundle exec mina setup domain=#{domain}"
end
