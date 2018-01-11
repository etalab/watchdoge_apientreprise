require 'forwardable'

class EndpointAvailabilityHistory
  include ActiveModel::Model
  extend Forwardable

  delegate %i[uname name api_version ping_url provider] => :endpoint
  attr_accessor :endpoint, :timezone, :availability_history

  validates :timezone, presence: true

  def initialize(hash)
    super
    @availability_history = AvailabilityHistory.new
  end

  def aggregate(code, timestamp)
    timestamp = Time.parse(timestamp).in_time_zone(@timezone).strftime('%F %T')
    @availability_history.aggregate(code, timestamp)
  end

  def sla
    @availability_history.sla
  end
end
