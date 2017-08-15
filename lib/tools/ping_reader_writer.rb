class Tools::PingReaderWriter
  def load_all_to_json
    File.new(status_file, 'w') unless File.exist?(status_file)
    content = File.read(status_file)
    content = '{}' if content.empty?

    JSON.parse(content)
  end

  def load(service_name, api_name, api_version)
    all_json = load_all_to_json

    return unless all_json.key?(api_name)

    json_pings = all_json[api_name].select do |ping|
      ping['name'] == service_name && ping['api_version'] == api_version
    end

    create_ping_from_json(json_pings)
  end

  def write(ping_status)
    @ping = ping_status
    @json = load_all_to_json

    create_api_key unless api_keys_exists?
    update_json

    File.write(status_file, @json.to_json)
  end

  private

  def status_file
    'tmp/status.json'
  end

  def api_keys_exists?
    (
      @json.key?(@ping.api_name) &&
      @json[@ping.api_name].class == Array
    )
  end

  def create_api_key
    @json[@ping.api_name] = []
  end

  def update_json
    @json[@ping.api_name].delete_if do |ping|
      ping['name'] == @ping.name && ping['api_version'] == @ping.api_version
    end

    @json[@ping.api_name] << @ping.as_json
  end

  def create_ping_from_json(json_pings)
    return unless json_pings.count.positive?
    if json_pings.count != 1
      Rails.logger.error "Multiple services found in JSON #{json_pings}"
    end

    PingStatus.new(json_pings.first)
  end
end
