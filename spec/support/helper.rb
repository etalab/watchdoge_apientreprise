def endpoints_count
  YAML.load_file('app/data/endpoints.yml').count
end

def providers_count
  14
end

class FakeWorker
  def run(elements)
    elements.each do |e|
      yield e
    end
  end
end

def create_random_ping_reports_for_all_endpoints
  endpoints = Tools::EndpointFactory.new('apie').load_all
  endpoints.each do |ep|
    create(:ping_report, name: ep.name, sub_name: ep.sub_name, api_version: ep.api_version, last_code: [200, 400].sample, first_downtime: Time.now)
  end
end

def create_ping_reports_for_all_endpoints
  endpoints = Tools::EndpointFactory.new('apie').load_all
  endpoints.each do |ep|
    create(:ping_report, name: ep.name, sub_name: ep.sub_name, api_version: ep.api_version)
  end
end
