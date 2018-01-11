class Tools::EndpointDatabaseFiller
  include Singleton

  def refill_database
    empty_database
    fill_database
    self
  end

  private

  def empty_database
    Endpoint.all.destroy_all
  end

  def fill_database
    endpoints.each do |endpoint|
      Endpoint.create(endpoint).save
    end
  end

  def endpoints
    YAML.load_file(endpoints_config_file)
  end

  def endpoints_config_file
    'app/data/endpoints.yml'
  end
end
