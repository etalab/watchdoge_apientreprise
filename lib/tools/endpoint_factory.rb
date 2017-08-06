class Tools::EndpointFactory

  def initialize
    @endpoints = []
  end

  def load_all
    hash = YAML.load_file(endpoint_config_file)

    hash['endpoints'].each do |h|
      endpoint = Endpoint.new(h)

      if endpoint.valid?
        @endpoints << endpoint
      else
        Rails.logger.error "Fail to load endpoint from YAML: #{h} errors: #{endpoint.errors.messages}"
      end
    end

    @endpoints
  end

  private

  def endpoint_config_file
    "#{Rails.root.to_s}/config/endpoints.yml"
  end
end
