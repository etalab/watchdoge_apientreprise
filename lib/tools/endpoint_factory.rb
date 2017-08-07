class Tools::EndpointFactory

  def initialize
    @endpoints = []
  end

  def create(name, version)
    load_all
    endpoint = nil
    @endpoints.select do |ep|
      if ep.name == name && ep.api_version == version
        endpoint = ep
      end
    end

    endpoint
  end

  def load_all
    load_from_yaml
    @endpoints
  end

  private

  def load_from_yaml
    @endpoints.clear
    hash = YAML.load_file(endpoint_config_file)

    hash['endpoints'].each do |h|
      endpoint = Endpoint.new(h)

      if endpoint.valid?
        @endpoints << endpoint
      else
        Rails.logger.error "Fail to load endpoint from YAML: #{h} errors: #{endpoint.errors.messages}"
      end
    end
  end

  def endpoint_config_file
    "#{Rails.root.to_s}/config/endpoints.yml"
  end
end
