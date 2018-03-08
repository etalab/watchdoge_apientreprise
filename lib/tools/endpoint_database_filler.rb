class Tools::EndpointDatabaseFiller
  def refill_database
    ActiveRecord::Base.transaction do
      # WARN: this is specific to Postgres
      ActiveRecord::Base.connection.execute("LOCK #{Endpoint.table_name} IN ACCESS EXCLUSIVE MODE")
      empty_database
      fill_database
    end
  end

  private

  def empty_database
    Endpoint.all.destroy_all
  end

  def fill_database
    endpoints.each do |endpoint|
      ep = Endpoint.create(endpoint)
      ep.save if ep.valid?
    end
  end

  def endpoints
    YAML.load_file(endpoints_config_file)
  end

  def endpoints_config_file
    'app/data/endpoints.yml'
  end
end
