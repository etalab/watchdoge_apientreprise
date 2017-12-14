class PingReport < ApplicationRecord
  validates :name, presence: true
  validates :api_version, numericality: { only_integer: true }, inclusion: { in: 1..3 }
  validates_uniqueness_of :name, scope: %i(sub_name api_version)
  validates :last_code, numericality: { only_integer: true }, inclusion: { in: 200..599 }, allow_nil: true
  validate :first_downtime_class

  def self.get_latest_where(hash)
    hash.delete_if { |key| !key.to_s.match(/(name|sub_name|api_version)/) }
    latest_report = PingReport.find_by(hash)

    if latest_report.nil?
      hash.merge!(last_code: 200, first_downtime: Time.now)
      PingReport.create(hash).tap(&:save)
    else
      latest_report
    end
  end

  def notify_new_ping(code, timestamp)
    @new_code = code
    @timestamp = timestamp
    update_state
    save
    self
  end

  def has_changed?
    @has_changed || false
  end

  def status
    case last_code
    when 200
      'UP'
    when 206
      'INCOMPLETE'
    else
      'DOWN'
    end
  end

  private

  def update_state
    if going_down?
      @has_changed = true
      self.last_code = @new_code
      self.first_downtime = @timestamp
    elsif going_up?
      @has_changed = true
      self.last_code = @new_code
    else
      @has_changed = false
    end
  end

  def going_down?
    ![200, 206].include?(@new_code) && ([200, 206].include?(last_code) || last_code.nil?)
  end

  def going_up?
    [200, 206].include?(@new_code) && (![200, 206].include?(last_code) || last_code.nil?)
  end

  def first_downtime_class
    first_downtime.is_a?(ActiveSupport::TimeWithZone)
  end
end
