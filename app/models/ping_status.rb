class PingStatus
  include ActiveModel::Model

  attr_accessor :name, :api_version, :date, :status

  validates :name, presence: true
  validates :api_version, numericality: { only_integer: true }, inclusion: { in: 2..3 }
  validates_datetime :date
  validates :status, inclusion: { in: ['up', 'down'] }

  def self.load_ping_status(service_name)
    self.new({name: service_name})
  end

  def self.load_all_to_json
    content = File.read(self.status_file)
    content = '{}' if content.empty?
    JSON.parse(content, symbolize_names: true)
  end

  def save
    if valid?
      all_json = self.class.load_all_to_json

      initialize_json!(all_json)
      update_json!(all_json)

      File.write(self.class.status_file, all_json)
    else
      fail 'cannot save: ping is invalid'
    end
  end

  def to_json(options = nil)
    super({only: ['name', 'api_version',  'date', 'status']}.merge(options || {}))
  end

  private

  def initialize_json!(json)
      if json.empty?
        json[:environment] = Rails.env
      end
  end

  def update_json!(json)
      all_json["v#{api_version}"].each do |service|
        if service[:name] == name
          service[:api_version] = api_version
          service[:status] = status
          service[:date] = date
        end
      end

  end

  def api_version_key_exists?(json)
    !json["v#{api_version}"].nil?
  end

  def self.status_file
    'tmp/status.json'
  end
end
