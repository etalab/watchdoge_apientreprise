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

    raise 'Need an argument! ie: `rake watch:v2_job associations`' if ARGV[1].nil?
    endpoint = Tools::EndpointFactory.new.create(ARGV[1], 2)
    ping = PingV2Job.new.perform_ping(endpoint)
    if ping.nil?
      puts "#{ARGV[1]} not found in endpoints.yml"
    else
      print_ping(ping)
    end
  end

  def print_ping(ping)
    ping.status.upcase!
    ping.status = ping.status == 'UP' ? ping.status.green : ping.status.red
    puts "#{ping.name}: #{ping.status}"
  end

  def env_info
    puts "Running on #{Rails.env.to_s.green} env (#{Rails.application.config_for(:watchdoge_secrets)['apie_base_uri']})"
  end
end
