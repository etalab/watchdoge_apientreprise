require 'colorize'

namespace :watch do
  desc 'run watchdoge job on API Entreprise v2'
  task 'apie_v2': :environment do
    env_info

    PingAPIEOnV2Job.new.perform do |ping|
      print_ping(ping)
    end
  end

  desc 'run watchdoge specific job on API Entreprise v2'
  task 'apie_v2_endpoint': :environment do
    # rubocop:disable Style/BlockDelimiters
    ARGV.each { |a| task a.to_sym do; end } # remove exit exception

    env_info
    raise 'Need an argument! ie: `rake watch:v2_job associations`'.red if ARGV[1].nil?

    endpoint = Tools::EndpointFactory.new('apie').create(ARGV[1], 2)
    raise "#{ARGV[1]} not found in endpoints.yml".red if endpoint.nil?

    ping = PingAPIEOnV2Job.new.perform_ping(endpoint)
    print_ping(ping)
  end

  desc 'run watchdoge in `store mode` so it automatically store http response for the futur checks'
  task 'store_responses': :environment do
    redefine_regeneration_mode
    env_info

    PingAPIEOnV2Job.new.perform do |ping|
      if ping.status == 'up'
        filename = "#{HTTPResponseValidator.response_folder}/#{ping.name}.json"
        File.new(filename, 'w') unless File.exist?(filename)
        File.write(filename, ping.json_response_body.to_json)

        puts "#{ping.name} response " + "stored".green + " (#{filename})"
      else
        puts "#{ping.name} ignored, service DOWN".red
      end
    end

    puts "You should manually check stored responses if they are correct!".red
  end

  def print_ping(ping)
    ping.status.upcase!
    failing_uri = ''
    if ping.status == 'UP'
      ping.status = ping.status.green
    else
      ping.status = ping.status.red
      failing_uri = PingAPIEOnV2Job.new.send(:request_url, Tools::EndpointFactory.new('apie').create(ping.name, ping.api_version))
    end

    puts "#{ping.name}: #{ping.status} #{failing_uri}"
  end

  def env_info
    puts "Running on #{Rails.env.to_s.green} env (#{Rails.application.config_for(:watchdoge_secrets)['apie_base_uri']})"
  end

  def redefine_regeneration_mode
    HTTPResponseValidator.class_eval do
      private
      def response_regeneration_mode
        true
      end
    end
  end
end
