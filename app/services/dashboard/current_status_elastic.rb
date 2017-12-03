class Dashboard::CurrentStatusElastic < Dashboard::AbstractElastic
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
      source = e.dig('agg_by_endpoint', 'hits', 'hits').first['_source']
      @values << Tools::ElasticsearchSourceParser.parse(source)
    end
  end
end
