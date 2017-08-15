class Endpoint
  include ActiveModel::Model

  attr_accessor :name, :api_version, :api_name, :parameter, :options, :response_regexp, :custom_url

  validates :name, presence: true
  # BLOCK any modification should be reported to PingStatus model
  validates :api_version, numericality: { only_integer: true }, inclusion: { in: 2..3 }
  validates :api_name, inclusion: { in: %w[apie sirene] }
  # END BLOCK
  validates :parameter, presence: true
  validates :options, presence: true
end
