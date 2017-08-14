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

  desc 'run watchdoge in `store mode` so it automatically store http response for the futur checks'
  # rake apie_v2:store_responses > do not update existsing files
  # rake apie_v2:store_responses true > update existing files
  task 'store_responses': :environment do
    redefine_regeneration_mode
    env_info
    force_mode = !ARGV[1].nil?

    PingAPIEOnV2Job.new.perform do |ping|
      if ping.status == 'up'
        filename = ping.response_file
        ignored = true
        if !File.exist?(filename) || force_mode
          File.new(filename, 'w') unless File.exist?(filename)
          File.write(filename, ping.json_response_body.to_json)
          ignored = false
        end

        if ignored
          puts "#{ping.name} response " + "ignored".cyan + " (file already exists)"
        else
          puts "#{ping.name} response " + "stored".green + " (#{filename})"
        end
      else
        puts "#{ping.name} ignored, service DOWN".red
      end
    end

    puts "\nYou should manually check stored responses if they are correct!".red
  end
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

