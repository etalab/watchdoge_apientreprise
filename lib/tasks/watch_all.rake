load './lib/tasks/tools.rake'
require 'colorize'

namespace :watch do
  desc 'run watchdoge service on all endpoints'
  task 'all': :environment do
    Rake::Task['apie_v1:all'].invoke
    Rake::Task['apie_v2:all'].invoke
  end
end
