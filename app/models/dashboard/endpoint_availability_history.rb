require 'forwardable'

class Dashboard::EndpointAvailabilityHistory
  include ActiveModel::Model
  extend Forwardable

  delegate %i[uname name api_version http_path provider] => :endpoint
  attr_accessor :endpoint, :timezone, :provider_name, :availability_history

  validates :timezone, presence: true

  def initialize(hash)
    super
    @availability_history = Dashboard::AvailabilityHistory.new
  end

  def aggregate(code, timestamp)
    timestamp = Time.zone.parse(timestamp).in_time_zone(@timezone).strftime('%F %T')
    @availability_history.aggregate(code, timestamp)
  end

  def sla
    @availability_history.sla
  end
end
