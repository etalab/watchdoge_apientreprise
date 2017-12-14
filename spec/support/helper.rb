def endpoints_count
  hash = YAML.load_file(subject.send(:endpoint_config_file))
  configfile_count = hash['endpoints'].count

  dir = 'app/models/endpoints'
  classfile_count = Dir[File.join(dir, '**', '*')].count { |file| File.file?(file) }

  configfile_count + classfile_count
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
