class PingStatus
  include ActiveModel::Model

  attr_accessor :name, :api_version, :date, :status

  validates :name, presence: true
  validates :api_version, numericality: { only_integer: true }, inclusion: { in: 2..3 }
  validates_datetime :date
  validates :status, inclusion: { in: ['up', 'down'] }

  def to_json(options = nil)
    super(json_options.merge(options || {}))
  end

  def as_json(options = nil)
    super(json_options.merge(options || {}))
  end

  private

  def json_options
    {only: ['name', 'api_version',  'date', 'status']}
  end
end
