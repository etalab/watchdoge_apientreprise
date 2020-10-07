class Stats::TauxDisposFournisseursService
  attr_reader :error, :endpoint_availability

  def initialize(endpoint, period = '6M')
    @endpoint = endpoint
    @period = period
    @client = ElasticClient.new
    @client.establish_connection
    @endpoint_availability = {}
  end

  def perform
    if @client.connected?
      @client.search(json_query)

      process_raw_response if @client.success?
    end
    self
  end

  def success?
    @success == true
  end

  private

  def process_raw_response
    if request_error?
      set_error
      @success = false
    else
      build_response_payload
      @success = true
    end
  end

  def build_response_payload
    @endpoint_availability[:endpoint] = @endpoint
    @endpoint_availability[:days_availability] = extract_daily_data_from_elk_payload
    @endpoint_availability[:total_availability] = compute_total_availability
    @endpoint_availability[:last_week_availability] = compute_last_week_availability
  end

  def request_error?
    endpoint_unknown? || invalid_period?
  end

  def endpoint_unknown?
    !aggs_result.nil? && aggs_result.empty?
  end

  def invalid_period?
    !elk_error.nil? && elk_error.any?
  end

  def aggs_result
    @aggs_result ||= @client.raw_response.dig('aggregations', '1d_interval', 'buckets')
  end

  def elk_error
    @elk_error ||= @client.raw_response.dig('_shards', 'failures')
  end

  def extract_daily_data_from_elk_payload
    aggs_result.each_with_object({}) do |daily_calls, res|
      formatted_date = daily_calls['key_as_string'].to_date.to_s
      res[formatted_date] = {
        'total' => daily_calls['doc_count'],
        '404' => extract_count_for_status(404, daily_calls),
        '502' => extract_count_for_status(502, daily_calls),
        '503' => extract_count_for_status(503, daily_calls),
        '504' => extract_count_for_status(504, daily_calls)
      }
    end
  end

  def extract_count_for_status(status, daily_result)
    res = daily_result['group_by_status']['buckets'].select { |h| h['key'] == status }

    res.empty? ? 0 : res.first['doc_count']
  end

  def compute_total_availability
    compute_availability(@endpoint_availability[:days_availability])
  end

  def compute_last_week_availability
    today = Time.zone.now.to_date
    last_week_days = (1..7).to_a.map { |i| (today - i).to_s }
    weekly_data = @endpoint_availability[:days_availability].select { |k, _v| last_week_days.include?(k) }
    compute_availability(weekly_data)
  end

  def compute_availability(period_data)
    total_call = 0
    total502 = 0
    period_data.each do |_k, v|
      total_call += v['total']
      total502 += v['502']
    end

    ((total_call - total502) / total_call.to_f * 100).round(2)
  end

  def set_error
    if endpoint_unknown?
      @error = { message: "No entry for endpoint `#{@endpoint}`" }
    elsif invalid_period?
      @error = { message: "Invalid period format `#{@period}`" }
    end
  end

  def json_query
    JSON.parse(load_query)
  end

  def load_query
    ERB.new(query_template).result(binding)
  end

  def query_template
    File.read('app/data/queries/provider_availability.json.erb')
  end
end
