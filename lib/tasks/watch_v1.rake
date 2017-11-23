load './lib/tasks/tools.rake'
require 'colorize'

namespace :watch_v1 do
  desc 'run watchdoge service on API Entreprise v1'
  task 'all', [:period] => :environment do |t, args|
    puts 'V1'.green unless ENV['RAILS_ENV'] == 'test'

    print_env_info

    hash_options = args.to_h

    PingAPIEOnV1.new(hash_options).perform do |ping, endpoint|
      print_ping(ping)
    end
  end

  desc 'run watchdoge on a specific service on API Entreprise v1: rake apie_v1:one associations'
  task 'one': :environment do
    print_env_info

    # rubocop:disable Style/BlockDelimiters
    ARGV.each { |a| task a.to_sym do; end } # it removes exit exception

    endpoint_name = ARGV[1]
    raise 'Need an argument! ie: `rake apie_v1:one associations`'.red if endpoint_name.nil?

    endpoint = Tools::EndpointFactory.new('apie').create(endpoint_name, 1)
    raise "#{endpoint_name} not found in endpoints.yml (and custom classes)".red if endpoint.nil?

    ping = PingAPIEOnV1.new.perform_ping(endpoint)
    print_ping(ping)
  end
end