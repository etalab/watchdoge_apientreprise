require 'colorize'

namespace :watch do
  desc 'run watchdoge job on API Entreprise v2'
  task :v2 => :environment do
    env_info

    PingV2Job.new.perform do |ping|
      print_ping(ping)
    end
  end

  desc 'run watchdoge specific job on API Entreprise v2'
  task :v2_job => :environment do
    ARGV.each { |a| task a.to_sym do ; end } # remove exit exception

    env_info

    raise 'Need an argument! ie: `rake watch:v2_job associations`'.red if ARGV[1].nil?

    endpoint = Tools::EndpointFactory.new.create(ARGV[1], 2)
    raise "#{ARGV[1]} not found in endpoints.yml".red if endpoint.nil?

    ping = PingV2Job.new.perform_ping(endpoint)
    print_ping(ping)
  end

  def print_ping(ping)
    ping.status.upcase!
    failing_uri = ''
    if ping.status == 'UP'
      ping.status = ping.status.green
    else
      ping.status = ping.status.red
      failing_uri = PingV2Job.new.send(:request_url, Tools::EndpointFactory.new.create(ping.name, ping.api_version))
    end

    puts "#{ping.name}: #{ping.status} #{failing_uri}"
  end

  def env_info
    puts "Running on #{Rails.env.to_s.green} env (#{Rails.application.config_for(:watchdoge_secrets)['apie_base_uri']})"
  end
end
