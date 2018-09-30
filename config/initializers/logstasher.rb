if LogStasher.enabled?
  LogStasher.add_custom_fields do |fields|
    fields[:type] = 'watchdoge'
    fields[:domain] = request.domain
  end
end
