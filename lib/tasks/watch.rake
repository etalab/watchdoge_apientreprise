require 'colorize'

# /!\ Any change in the name MUST be impacted in schedule.rb
namespace :watch do
  desc 'run watchdoge service on all endpoints'
  task 'all': :environment do
    Endpoint.all.each do |ep|
      PingWorker.perform_async(ep.uname)
      print_infos(ep)
    end
  end

  desc 'run watchdoge service on all endpoints with a period of 1 minute'
  task 'period_1': :environment do
    puts 'Period 1' unless ENV['RAILS_ENV'] == 'test'
    Endpoint.where(ping_period: 1).each do |ep|
      PingWorker.perform_async(ep.uname)
      print_infos(ep)
    end
  end

  desc 'run watchdoge service on all endpoints with a period of 5 minute'
  task 'period_5': :environment do
    puts 'Period 5' unless ENV['RAILS_ENV'] == 'test'
    Endpoint.where(ping_period: 5).each do |ep|
      PingWorker.perform_async(ep.uname)
      print_infos(ep)
    end
  end

  desc 'run watchdoge service on all endpoints with a period of 60 minutes'
  task 'period_60': :environment do
    puts 'Period 60' unless ENV['RAILS_ENV'] == 'test'
    Endpoint.where(ping_period: 60).each do |ep|
      PingWorker.perform_async(ep.uname)
      print_infos(ep)
    end
  end

  def print_infos(endpoint)
    url = ENV['DEBUG'] ? "(url: #{endpoint.uri})" : ''
    puts "#{endpoint.uname.green} added to sidekiq #{url}" unless ENV['RAILS_ENV'] == 'test'
  end
end
