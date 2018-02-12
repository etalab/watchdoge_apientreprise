task 'refill_database': :environment do
  if ActiveRecord::Base.connection.table_exists? 'endpoints'
    Tools::EndpointDatabaseFiller.new.refill_database
  end
end
