class Dashboard::AvailabilityHistoryElastic < Dashboard::AbstractElastic
  def get
    process_query do
      get_raw_response 'availability_history'
      process_raw_availability_history
    end
  end

  private

  def process_raw_availability_history
    @historical_data = {}
    compute_all_availability_history
    compute_all_sla

    @historical_data.each do |key, value|
      @values << value
    end
  end

  def compute_all_sla
    @historical_data.each do |key, value|
      compute_sla value
    end
  end

  def compute_sla(data)
    data[:sla] = (
      (
        1.0 - down_duration(data) / full_range_duration(data)
      )*100
    ).round(2)
  end

  def full_range_duration(data)
    from = DateTime.parse(data[:availabilities].first.first)
    to = DateTime.parse(data[:availabilities].last.last)
    interval_to_seconds(to - from)
  end

  def down_duration(data)
    down_time = data[:availabilities].map do |d|
      if d[1] == 0
        from = DateTime.parse(d[0])
        to = DateTime.parse(d[2])
        interval_to_seconds(to - from)
      end
    end

    down_time.compact.inject(0, :+)
  end

  def interval_to_seconds(interval)
    (interval * 24 * 60 * 60).to_f
  end

  def compute_all_availability_history
    raw_datas = @raw_response.dig('hits', 'hits')

    raw_datas.each do |raw_data|
      @current = ping_infos_from_elasticsearch raw_data['_source']

      if new_name?
        add_new_key
      end

      compute_availability
    end
  end

  def add_new_key
    @historical_data[@current[:fullname]] = {
      name: @current[:name],
      subname: @current[:subname],
      version: @current[:version],
      sla: 0.0,
      availabilities: []
    }
  end

  def compute_availability
    if (current_availabilities.size == 0)
      add_new_availability
    else
      update_last_availability
    end
  end

  def add_new_availability
    current_availabilities << [
      current_timestamp,
      current_status_code,
      current_timestamp
    ]
  end

  def update_last_availability
    if (last_status_code == current_status_code)
      last_availability[2] = current_timestamp
    else
      add_new_availability
    end
  end

  def current_status_code
    @current[:code] == 200 ? 1 : 0
  end

  def current_availabilities
    @historical_data[@current[:fullname]][:availabilities]
  end

  def current_timestamp
    DateTime.parse(@current[:timestamp]).strftime('%F %T')
  end

  def last_availability
    current_availabilities.last
  end

  def last_status_code
    last_availability[1]
  end

  def new_name?
    !@historical_data.key?(@current[:fullname])
  end
end
