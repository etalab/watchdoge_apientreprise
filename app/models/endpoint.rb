class Endpoint
  include ActiveModel::Model

  attr_accessor :name, :api_version, :api_name, :parameter, :options, :custom_url

  validates :name, presence: true
  validates :api_version, numericality: { only_integer: true }, inclusion: { in: 2..3 }
  validates :api_name, presence: true
  validates :parameter, presence: true
  validates :options, presence: true
end
