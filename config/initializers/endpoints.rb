if %w[production sandbox].include?(Rails.env)
  Tools::EndpointDatabaseFiller.instance.refill_database
end
