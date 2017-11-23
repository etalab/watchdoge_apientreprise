load './lib/tasks/tools.rake'
require 'colorize'

namespace :watch do
  desc 'run watchdoge service on all endpoints'
  task 'all': :environment do
    Rake::Task['watch_sirene:all'].invoke
    Rake::Task['watch_v1:all'].invoke
    Rake::Task['watch_v2:all'].invoke
  end

  desc 'run watchdoge service on all endpoints with a period of 1 minute'
  task 'period_1': :environment do # /!\ Any change in the name MUST be impacted in schedule.rb
    Rake::Task['watch_sirene:all'].invoke(1)
    Rake::Task['watch_v1:all'].invoke(1)
    Rake::Task['watch_v2:all'].invoke(1)
  end

  desc 'run watchdoge service on all endpoints with a period of 5 minute'
  task 'period_5': :environment do # /!\ Any change in the name MUST be impacted in schedule.rb
    Rake::Task['watch_v1:all'].invoke(5)
    Rake::Task['watch_v2:all'].invoke(5)
  end

  desc 'run watchdoge service on all endpoints with a period of 60 minutes'
  task 'period_60': :environment do # /!\ Any change in the name MUST be impacted in schedule.rb
    Rake::Task['watch_v1:all'].invoke(60)
    Rake::Task['watch_v2:all'].invoke(60)
  end
end
