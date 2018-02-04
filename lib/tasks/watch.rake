require 'colorize'

# /!\ Any change in the name MUST be impacted in schedule.rb
namespace :watch do
  desc 'run watchdoge service on one specific endpoint into sidekiq'
  task one_sidekiq: :environment do
    ARGV.each { |a| task a.to_sym do; end } # it removes exit exception

    uname = ARGV[1]
    perform_async uname
  end

  desc 'run watchdoge service on all endpoints with a period of 1 minute'
  task 'period_1': :environment do
    watch(period: 1)
  end

  desc 'run watchdoge service on all endpoints with a period of 5 minute'
  task 'period_5': :environment do
    watch(period: 5)
  end

  desc 'run watchdoge service on all endpoints with a period of 60 minutes'
  task 'period_60': :environment do
    watch(period: 60)
  end

  def watch(period:)
    puts "Period #{period}" if Rails.env.development?
    Endpoint.where(ping_period: period).each do |endpoint|
      perform_async endpoint
    end
  end

  def perform_async(endpoint)
    PingWorker.perform_async(endpoint.uname)
    print_sidekiq_infos(endpoint)
  end

  def print_sidekiq_infos(endpoint)
    url = ENV['DEBUG'] ? "(url: #{endpoint.uri})" : ''
    puts "#{endpoint.uname.blue} added to sidekiq #{url}" if Rails.env.development?
  end
end
