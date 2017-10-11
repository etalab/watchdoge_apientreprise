load './lib/tasks/tools.rake'
require 'colorize'

namespace :apie_v1 do
  desc 'run watchdoge job on API Entreprise v1'
  task 'all': :environment do
    env_info

    PingAPIEOnV1Job.new.perform do |ping|
      print_ping(ping)
    end
  end

  desc 'run watchdoge on a specific job on API Entreprise v1: rake apie_v1:one associations'
  task 'one': :environment do
    env_info

    # rubocop:disable Style/BlockDelimiters
    ARGV.each { |a| task a.to_sym do; end } # it removes exit exception

    endpoint_name = ARGV[1]
    raise 'Need an argument! ie: `rake apie_v1:one associations`'.red if endpoint_name.nil?

    endpoint = Tools::EndpointFactory.new('apie').create(endpoint_name, 1)
    raise "#{endpoint_name} not found in endpoints.yml (and custom classes)".red if endpoint.nil?

    ping = PingAPIEOnV1Job.new.perform_ping(endpoint)
    print_ping(ping)
  end
end
