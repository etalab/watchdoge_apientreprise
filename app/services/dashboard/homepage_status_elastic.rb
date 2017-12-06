class Dashboard::HomepageStatusElastic < Dashboard::AbstractElastic
  def get
    get_raw_response load_query('homepage_status')
    process_raw_homepage_status if success?
    self
  end

  private

  def process_raw_homepage_status
    raw_endpoint = @raw_response.dig('hits', 'hits', 0, '_source')
    endpoint = {
      'name': 'APIE Homepage',
      'code': raw_endpoint.dig('status'),
      'timestamp': raw_endpoint.dig('@timestamp')
    }

    @values << endpoint
  end
end
