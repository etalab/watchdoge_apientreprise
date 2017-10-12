load './lib/tasks/tools.rake'
require 'colorize'

namespace :apie_v1 do
  desc 'run watchdoge service  on API Entreprise v1'
  task 'all': :environment do
    env_info

    PingAPIEOnV1.new.perform do |ping, endpoint|
      request_url = PingAPIEOnV1.new.send(:request_url, endpoint)
      print_ping(ping, request_url)
    end
  end

  desc 'run watchdoge on a specific service on API Entreprise v1: rake apie_v1:one associations'
  task 'one': :environment do
    env_info

    # rubocop:disable Style/BlockDelimiters
    ARGV.each { |a| task a.to_sym do; end } # it removes exit exception

    endpoint_name = ARGV[1]
    raise 'Need an argument! ie: `rake apie_v1:one associations`'.red if endpoint_name.nil?

    endpoint = Tools::EndpointFactory.new('apie').create(endpoint_name, 1)
    raise "#{endpoint_name} not found in endpoints.yml (and custom classes)".red if endpoint.nil?

    service = PingAPIEOnV1.new
    request_url = service.send(:request_url, endpoint)
    ping = service.perform_ping(endpoint)

    print_ping(ping, request_url)
  end
end
