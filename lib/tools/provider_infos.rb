class Tools::ProviderInfos
  include Singleton

  # match provider_infos_list json schema
  def all
    initialize_json
    fill_json
    @json
  end

  private

  def initialize_json
    @json = Endpoint.all.map do |ep|
      { uname: ep.provider, endpoints_unames: [] }
    end.uniq
  end

  def fill_json
    Endpoint.all.each do |ep|
      provider = @json.select { |p| p[:uname] == ep.provider}.first
      provider[:endpoints_unames] << ep.uname
    end
  end
end