class Endpoint
  include ActiveModel::Model

  attr_accessor :name, :api_version, :parameter, :options

  validates :name, presence: true
  validates :api_version, numericality: { only_integer: true }, inclusion: { in: 2..3 }
  validates :parameter, presence: true
  validates :options, presence: true
end
