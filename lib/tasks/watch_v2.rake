load './lib/tasks/tools.rake'
require 'colorize'

namespace :apie_v2 do
  desc 'run watchdoge job on API Entreprise v2'
  task 'all': :environment do
    env_info

    PingAPIEOnV2Job.new.perform do |ping, endpoint|
      request_url = PingAPIEOnV2Job.new.send(:request_url, endpoint)
      print_ping(ping, request_url)
    end
  end

  desc 'run watchdoge on a specific job on API Entreprise v2: rake apie_v2:one associations'
  task 'one': :environment do
    env_info

    # rubocop:disable Style/BlockDelimiters
    ARGV.each { |a| task a.to_sym do; end } # it removes exit exception

    endpoint_name = ARGV[1]
    raise 'Need an argument! ie: `rake apie_v2:one associations`'.red if endpoint_name.nil?

    endpoint = Tools::EndpointFactory.new('apie').create(endpoint_name, 2)
    raise "#{endpoint_name} not found in endpoints.yml (and custom classes)".red if endpoint.nil?

    job = PingAPIEOnV2Job.new
    request_url = job.send(:request_url, endpoint)
    ping = job.perform_ping(endpoint)

    print_ping(ping, request_url)
  end
end
