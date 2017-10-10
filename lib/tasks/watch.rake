require 'colorize'

namespace :apie_v2 do
  desc 'run watchdoge job on API Entreprise v2'
  task 'all': :environment do
    env_info

    PingAPIEOnV2Job.new.perform do |ping|
      print_ping(ping)
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

    ping = PingAPIEOnV2Job.new.perform_ping(endpoint)
    print_ping(ping)
  end
end

def print_ping(ping)
  status, debug_info = ''
  case ping.status
  when 'up'
    status = ping.status.upcase.green

  when 'incomplete'
    status = ping.status.upcase.yellow

  when 'down'
    status = ping.status.upcase.red
    debug_info = PingAPIEOnV2Job.new.send(:request_url, Tools::EndpointFactory.new('apie').create(ping.name, 2))
  end

  puts "#{ping.name}: #{status} #{debug_info}"
end

def env_info
  puts "Running on #{Rails.env.to_s.green} env (#{Rails.application.config_for(:watchdoge_secrets)['apie_base_uri']}) with #{Rails.application.config.thread_number.to_s.yellow} threads"
end
