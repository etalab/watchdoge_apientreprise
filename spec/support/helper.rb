def endpoints_count
  YAML.load_file('app/data/endpoints.yml').count
end

def providers_count
  14
end

def create_random_ping_reports_for_all_endpoints
  Endpoint.all.each do |ep|
    create(:ping_report, uname: ep.uname, last_code: [200, 400].sample, first_downtime: Time.now)
  end
end

def create_ping_reports_for_all_endpoints
  Endpoint.all.each do |ep|
    create(:ping_report, uname: ep.uname)
  end
end
