class PingStatus
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name, :api_version, :api_name, :date, :status, :environment, :http_response

  validates :name, presence: true
  # BLOCK any modification should be reported to Endpoint model
  validates :api_version, numericality: { only_integer: true }, inclusion: { in: 2..3 }
  validates :api_name, inclusion: { in: %w[apie sirene] }
  # END BLOCK
  validates_datetime :date
  validates :status, inclusion: { in: %w[up down] }
  validates :environment, inclusion: { in: %w[development test sandbox staging production] }
  validates_with HTTPResponseValidator

  def json_response_body
    return if http_response.nil?

    begin
      JSON.parse(http_response.body)
    rescue
      {}
    end
  end

  def to_json(options = nil)
    super(json_options.merge(options || {}))
  end

  def as_json(options = nil)
    super(json_options.merge(options || {}))
  end

  def response_file
    "%s/%s.json" % [response_folder, name]
  end

  # for debugging purpose its unreadable with http_response on screen
  def inspect
    vars = instance_variables
           .map { |v| "#{v}=#{instance_variable_get(v).inspect}" unless v == :@http_response }
           .join(', ')
    "<#{self.class}: #{vars}>"
  end

  private

  def json_options
    { only: %w[name api_version api_name date status environment] }
  end

  def response_folder
    "app/data/responses/#{api_name}"
  end
end
