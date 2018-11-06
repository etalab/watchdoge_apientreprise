class Dashboard::AvailabilityHistory
  def initialize
    @availability_history = []
  end

  def aggregate(code, time)
    @code = code
    @time = time

    return false unless valid_parameters?

    add_or_update
    true
  end

  def sla
    ((1.0 - down_duration / full_range_duration) * 100).round(2)
  end

  def to_a
    @availability_history
  end

  private

  def valid_parameters?
    valid_code? && valid_time?
  end

  def valid_code?
    # 200: OK, 206: Partial Response, 212: OK (backup used), 500, KO, 512: KO (backup used)
    [200, 206, 212, 500, 512].include?(@code)
  end

  def valid_time?
    @time =~ /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/
  end

  def add_or_update
    if @availability_history.size.zero?
      add_new_availability
    else
      update_last_availability
    end
  end

  def add_new_availability
    @availability_history << [
      @time,
      @code,
      @time
    ]
  end

  def update_last_availability
    last_availability[2] = @time

    add_new_availability if code_changed?
  end

  def code_changed?
    last_status_code != @code
  end

  def last_status_code
    last_availability[1]
  end

  def last_availability
    @availability_history.last
  end

  def full_range_duration
    from = Time.zone.parse(@availability_history.first.first)
    to = Time.zone.parse(@availability_history.last.last)

    interval_to_seconds(to - from)
  end

  def down_duration
    down_time = @availability_history.map do |history|
      http_code = history[1]
      next if http_code < 300 # means it's UP

      from = Time.zone.parse(history[0])
      to = Time.zone.parse(history[2])
      interval_to_seconds(to - from)
    end

    down_time.compact.inject(0, :+)
  end

  def interval_to_seconds(interval)
    (interval * 24 * 60 * 60).to_f
  end
end
