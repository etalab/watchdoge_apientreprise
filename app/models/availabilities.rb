class Availabilities
  def initialize
    @availabilities = []
  end

  def add_history(code, datetime)
    @code = code
    @datetime = datetime

    return false unless valid?

    add_or_update
    true
  end

  def sla
    ((1.0 - down_duration / full_range_duration) * 100).round(2)
  end

  def to_a
    @availabilities
  end

  private

  def valid?
    valid_code? && valid_datetime?
  end

  def valid_code?
    [0, 1].include?(@code)
  end

  def valid_datetime?
    @datetime =~ /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/
  end

  def add_or_update
    if (@availabilities.size == 0)
      add_new_availability
    else
      update_last_availability
    end
  end

  def add_new_availability
    @availabilities << [
      @datetime,
      @code,
      add_one_minute
    ]
  end

  def update_last_availability
    if (last_status_code == @code)
      last_availability[2] = @datetime
    else
      add_new_availability
    end
  end

  def last_status_code
    last_availability[1]
  end

  def last_availability
    @availabilities.last
  end

  def full_range_duration
    from = DateTime.parse(@availabilities.first.first)
    to = DateTime.parse(@availabilities.last.last)
    interval_to_seconds(to - from)
  end

  def down_duration
    down_time = @availabilities.map do |d|
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

  def add_one_minute
    datetime = DateTime.parse(@datetime)
    datetime = datetime + 1.minutes
    datetime.strftime('%F %T')
  end
end
