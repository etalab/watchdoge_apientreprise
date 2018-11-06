task 'refill_database': :environment do
  # rubocop:disable Style/IfUnlessModifier
  if ActiveRecord::Base.connection.table_exists? 'endpoints'
    Tools::EndpointDatabaseFiller.new.refill_database
  end
  # rubocop:enable Style/IfUnlessModifier
end
