class Endpoint
  include ActiveModel::Model

  attr_accessor :name, :sub_name, :api_version, :api_name, :period, :parameter, :options, :specific_url

  validates :name, presence: true
  validates :api_version, numericality: { only_integer: true }, inclusion: { in: 1..3 }
  validates :api_name, presence: true
  validates :period, numericality: { only_integer: true}, inclusion: { in: [1, 5, 60] } # if you add a period add a schedule in config/schedule.rb !
  validates :parameter, presence: true
  validates :options, presence: true

  def fullname
    return name unless sub_name
    "#{sub_name}/#{name}"
  end
end
