class Tools::EndpointFactory
  def initialize(api_name)
    @api_name = api_name
    @endpoints = []
  end

  def create(name, version)
    load_all
    endpoint = nil
    @endpoints.select do |ep|
      endpoint = ep if ep.name == name && ep.api_version == version
    end

    endpoint
  end

  def load_all
    @endpoints.clear
    load_from_yaml
    load_specific_endpoints
    @endpoints
  end

  private

  def load_from_yaml
    hash = YAML.load_file(endpoint_config_file)

    hash['endpoints'].each do |h|
      endpoint = Endpoint.new(h.merge(api_name: @api_name))

      if endpoint.valid?
        @endpoints << endpoint
      else
        Rails.logger.error "Fail to load endpoint from YAML: #{h} errors: #{endpoint.errors.messages}"
      end
    end
  end

  def load_specific_endpoints
    return if @apie_name

    endpoints_files.each do |file|
      ep = classify(file).constantize.new
      @endpoints << ep if ep.api_name == @api_name
    end
  end

  def classify(file)
    'Endpoints::' + File.basename(file, '.rb').classify
  end

  def endpoints_files
    dir = 'app/models/endpoints'
    Dir[File.join(dir, '**', '*')]
  end

  def endpoint_config_file
    Rails.root.join('app', 'data', 'endpoints', "#{@api_name}.yml")
  end
end
