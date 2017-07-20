class ApplicationJob < ActiveJob::Base
  attr_accessor :logger

  def initialize
    self.logger = Ougai::Logger.new(self.class.logfile)
    self.logger.default_message = 'ping'
  end

  private

  def self.logfile
    "log/logstash_ping_#{Rails.env}.log"
  end
end
