def endpoints_count
  YAML.load_file('app/data/endpoints.yml').count
end
