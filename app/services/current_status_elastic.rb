class CurrentStatusElastic < AbstractElastic
  def get
    process_query do
      get_raw_response 'current_status'
      process_raw_current_status
    end
  end

  private

  def process_raw_current_status
    raw_endpoints = @raw_response.dig('aggregations', 'group_by_controller', 'buckets')
    raw_endpoints.each do |e|
      raw_data = e.dig('agg_by_endpoint', 'hits', 'hits').first['_source']
      @values << ping_infos_from_elasticsearch(raw_data)
    end
  end
end
