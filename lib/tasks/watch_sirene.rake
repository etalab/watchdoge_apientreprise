load './lib/tasks/tools.rake'
require 'colorize'

namespace :watch_sirene do
  desc 'run watchdoge service on sirene as API'
  task 'all', [:period] => :environment do |_, args|
    puts "Running on #{Rails.env.to_s.green} env (#{Rails.application.config_for(:secrets)['sirene_base_uri']}) with #{Rails.application.config.thread_number.to_s.yellow} threads" unless ENV['RAILS_ENV'] == 'test'
    hash_options = args.to_h

    PingSirene.new(hash_options).perform do |ping, _|
      print_ping(ping)
    end
  end
end
