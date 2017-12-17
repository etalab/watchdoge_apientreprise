class Tools::ElasticsearchSourceParser
  def self.parse(source)
    api_version, name, sub_name = source['controller'].split('/').slice(1, 4)
    api_version = api_version.tr('v', '').to_i
    status = source['status']
    timestamp = source['@timestamp']

    # For liasse_fiscales_dgfip dictionnaire/complete/declaration
    if name =~ /liasses_fiscales_dgfip/ && api_version == 2
      sub_name = source['action']
    end

    {
      name: name,
      sub_name: sub_name,
      api_version: api_version,
      code: status,
      timestamp: timestamp
    }
  end
end
