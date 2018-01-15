require 'colorize'

# These tasks are for local development and have no tests
namespace :watch do
  desc 'refill development database'
  task 'refill': :environment do
    puts 'Dropping Endpoint database... refilling database...'.blue
    Tools::EndpointDatabaseFiller.instance.refill_database
  end

  desc 'run watchdoge service on all endpoints'
  task 'all': :refill do
    Endpoint.all.each do |endpoint|
      endpoint.http_response
      print_console_infos endpoint
    end
  end

  desc 'run a specific endpoint by uname'
  task 'one': :refill do
    # rubocop:disable Style/BlockDelimiters
    ARGV.each { |a| task a.to_sym do; end } # it removes exit exception

    endpoint = Endpoint.find_by(uname: ARGV[1])
    endpoint.http_response
    print_console_infos endpoint
  end

  def print_console_infos(endpoint)
    url = ENV['DEBUG'] ? "(url: #{endpoint.uri})" : ''
    puts "#{endpoint.uname.blue} is #{status(endpoint)} #{url}" unless ENV['RAILS_ENV'] == 'test'
  end

  def status(endpoint)
    case endpoint.http_response.code.to_i
      when 200
        'UP'.green
      when 206
        'INCOMPLETE'.yellow
      else
        'DOWN'.red
    end
  end
end