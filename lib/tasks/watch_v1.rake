load './lib/tasks/tools.rake'
require 'colorize'

namespace :watch_v1 do
  desc 'run watchdoge service on API Entreprise v1'
  task 'all', [:period] => :environment do |_, args|
    puts 'V1'.green unless ENV['RAILS_ENV'] == 'test'

    print_env_info_v1

    hash_options = args.to_h

    PingAPIEOnV1.new(hash_options).perform do |ping, _|
      print_ping(ping)
    end
  end

  desc 'run watchdoge on a specific service on API Entreprise v1: rake apie_v1:one associations'
  task 'one': :environment do
    print_env_info_v1

    # rubocop:disable Style/BlockDelimiters
    ARGV.each { |a| task a.to_sym do; end } # it removes exit exception

    endpoint_name = ARGV[1]
    raise 'Need an argument! ie: `rake apie_v1:one associations`'.red if endpoint_name.nil?

    endpoint = Tools::EndpointFactory.new('apie').create(endpoint_name, 1)
    raise "#{endpoint_name} not found in endpoints.yml (and custom classes)".red if endpoint.nil?

    ping = PingAPIEOnV1.new.perform_ping(endpoint)
    print_ping(ping)
  end

  def print_env_info_v1
    puts "Running on #{Rails.env.to_s.green} env (#{Rails.application.config_for(:secrets)['apie_base_uri_old']}) with #{Rails.application.config.thread_number.to_s.yellow} threads" unless ENV['RAILS_ENV'] == 'test'
  end
end
