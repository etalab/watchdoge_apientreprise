def print_ping(ping)
  status = compute_status(ping.status)
  debug_info = ping.url if ping.status == 'down' || ENV['DEBUG']
  puts "#{ping.name}: #{status} #{debug_info}" unless ENV['RAILS_ENV'] == 'test'
end

def compute_status(status)
  case status
  when 'up'
    status.upcase.green

  when 'incomplete'
    status.upcase.yellow

  when 'down'
    status.upcase.red
  end
end
