# no header in the log file !
class Logger::LogDevice
  # re-open Logger class to override add_log_header
  def add_log_header(file)
  end
end
