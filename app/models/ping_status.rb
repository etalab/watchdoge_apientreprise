class PingStatus
  include ActiveModel::Model

  attr_accessor :name, :date, :code

  validates :name, presence: true
  validates_datetime :date, :before => DateTime.now
  validates :code, numericality: { only_integer: true }

  def save

  end

  def as_json(options = nil)
    super({only: ['name', 'date', 'code']}.merge(options || {}))
  end
end
