def print_ping(ping, request_url)
  status, debug_info = ''
  case ping.status
  when 'up'
    status = ping.status.upcase.green

  when 'incomplete'
    status = ping.status.upcase.yellow

  when 'down'
    status = ping.status.upcase.red
  end

  debug_info = request_url if ping.status == 'down' || ENV['DEBUG']
  puts "#{ping.name}: #{status} #{debug_info}" unless ENV['RAILS_ENV'] = 'test'
end

def env_info
  puts "Running on #{Rails.env.to_s.green} env (#{Rails.application.config_for(:secrets)['apie_base_uri']}) with #{Rails.application.config.thread_number.to_s.yellow} threads" unless ENV['RAILS_ENV'] = 'test'

end
