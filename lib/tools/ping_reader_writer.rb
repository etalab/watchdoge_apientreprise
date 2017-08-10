class Tools::PingReaderWriter
  def load_all_to_json
    content = File.read(status_file)
    content = '{}' if content.empty?
    json = JSON.parse(content, symbolize_names: true)

    initialize_json(json)
  end

  def load(service_name, api_version)
    all_json = load_all_to_json
    version = ('v' + api_version.to_s).to_sym

    return unless all_json.key?(version)
    json_pings = all_json[version].select do |ping|
      ping[:name] == service_name
    end

    create_ping_from_json(json_pings)
  end

  def write(ping_status)
    @ping = ping_status
    @version_sym = ('v' + @ping.api_version.to_s).to_sym
    @json = load_all_to_json

    create_key unless keys_exists?
    update_json

    File.write(status_file, @json.to_json)
  end

  private

  def status_file
    'tmp/status.json'
  end

  def initialize_json(json)
    json[:environment] = Rails.env if json.empty? || !json.key?(:environment)
    json
  end

  def keys_exists?
    (
      @json.key?(@version_sym) &&
      @json[@version_sym].class == Array
    )
  end

  def create_key
    @json[@version_sym] = []
  end

  def update_json
    @json[@version_sym].delete_if do |ping|
      ping[:name] == @ping.name
    end

    @json[@version_sym] << @ping.as_json
  end

  def create_ping_from_json(json_pings)
    return unless json_pings.count.positive?
    if json_pings.count != 1
      Rails.logger.error "Multiple services found in JSON #{json_pings}"
    end

    PingStatus.new(json_pings.first)
  end
end
