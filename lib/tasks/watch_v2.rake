load './lib/tasks/tools.rake'
require 'colorize'

namespace :watch_v2 do
  desc 'run watchdoge service on API Entreprise v2'
  task 'all', [:period] => :environment do |_, args|
    puts 'V2'.green unless ENV['RAILS_ENV'] == 'test'

    print_env_info_v2

    hash_options = args.to_h

    PingAPIEOnV2.new(hash_options).perform do |ping, _|
      print_ping(ping)
    end
  end

  desc 'run watchdoge on a specific service on API Entreprise v2: rake apie_v2:one associations'
  task 'one': :environment do
    print_env_info_v2

    # rubocop:disable Style/BlockDelimiters
    ARGV.each { |a| task a.to_sym do; end } # it removes exit exception

    endpoint_name = ARGV[1]
    raise 'Need an argument! ie: `rake apie_v2:one associations`'.red if endpoint_name.nil?

    endpoint = Tools::EndpointFactory.new('apie').create(endpoint_name, 2)
    raise "#{endpoint_name} not found in endpoints.yml (and custom classes)".red if endpoint.nil?

    ping = PingAPIEOnV2.new.perform_ping(endpoint)
    print_ping(ping)
  end

  def print_env_info_v2
    puts "Running on #{Rails.env.to_s.green} env (#{Rails.application.config_for(:secrets)['apie_base_uri_new']}) with #{Rails.application.config.thread_number.to_s.yellow} threads" unless ENV['RAILS_ENV'] == 'test'
  end
end
