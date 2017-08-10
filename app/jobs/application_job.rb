class ApplicationJob < ActiveJob::Base
  attr_accessor :logger

  def initialize
    @logger = Ougai::Logger.new(self.class.logfile)
    @logger.default_message = 'ping'
  end

  private_class_method

  def self.logfile
    "log/logstash_ping_#{Rails.env}.log"
  end
end
