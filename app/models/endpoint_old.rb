class EndpointOld
  include ActiveModel::Model

  attr_accessor :name, :sub_name, :provider, :api_version, :api_name, :period, :parameter, :options, :specific_url

  validates :name, presence: true
  validates :provider, presence: true
  validates :api_version, numericality: { only_integer: true }, inclusion: { in: 1..3 }
  validates :api_name, presence: true
  validates :period, numericality: { only_integer: true }, inclusion: { in: [1, 5, 60] } # if you add a period add a schedule in config/schedule.rb !
  validates :parameter, presence: true
  validates :options, presence: true

  def full_name
    return name unless sub_name
    "#{sub_name}/#{name}"
  end

  def id
    "#{name}_#{sub_name}_#{api_version}".tr(' ', '_')
  end
end
