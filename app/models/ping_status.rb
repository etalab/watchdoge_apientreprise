class PingStatus
  include ActiveModel::Model

  attr_accessor :name, :api_version, :date, :status, :environment, :http_response

  validates :name, presence: true
  validates :api_version, numericality: { only_integer: true }, inclusion: { in: 2..3 }
  validates_datetime :date
  validates :status, inclusion: { in: %w[up down] }
  validates :environment, inclusion: { in: %w[development test sandbox staging production] }

  def to_json(options = nil)
    super(json_options.merge(options || {}))
  end

  def as_json(options = nil)
    super(json_options.merge(options || {}))
  end

  # for debugging purpose its unreadable with htt_response on screen
  def inspect
    vars = instance_variables
           .map { |v| "#{v}=#{instance_variable_get(v).inspect}" unless v == :@http_response }
           .join(', ')
    "<#{self.class}: #{vars}>"
  end

  private

  def json_options
    { only: %w[name api_version date status environment] }
  end
end
