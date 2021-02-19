# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

watchdoge = 'watchdoge.entreprise.api.gouv.fr'
wd2 = 'wd2.entreprise.api.gouv.fr'

domains = [watchdoge, wd2]

task :deploy_server do
  domains.each do |domain|
    sh "bundle exec mina deploy domain=#{domain}"
  end
end

task :setup_server do
  domains.each do |domain|
    sh "bundle exec mina setup domain=#{domain}"
  end
end
