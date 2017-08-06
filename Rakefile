# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task :deploy_server do
  domain = 'ns3073182.ip-217-182-164.eu'
  sh "bundle exec mina deploy domain=#{domain}"
end
