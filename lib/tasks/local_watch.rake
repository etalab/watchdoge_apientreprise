require 'colorize'

# These tasks are for local development and have no tests
namespace :watch do
  desc 'run watchdoge service on all endpoints'
  task 'all': :environment do
    Endpoint.all.each do |endpoint|
      endpoint.http_response
      print_console_infos endpoint
    end
  end

  desc 'run a specific endpoint by uname'
  task 'one': :environment do
    # rubocop:disable Style/BlockDelimiters
    ARGV.each { |a| task a.to_sym do; end } # it removes exit exception

    endpoint = Endpoint.find_by(uname: ARGV[1])
    endpoint.http_response
    print_console_infos endpoint
  end

  def print_console_infos(endpoint)
    url = ENV['DEBUG'] ? "(url: #{endpoint.uri})" : ''
    puts "#{endpoint.uname.blue} is #{status(endpoint)} #{url}" if ENV['RAILS_ENV'] == 'development'
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