FactoryBot.define do
  factory :endpoint do
    uname { 'apie_2_certificats_test' }
    name { 'Certificats Test' }
    api_name { 'apie' }
    api_version { 2 }
    provider { 'qualibat' }
    ping_period { 60 }
    http_path { '/v2/certificats_test/33592022900036' }
    http_query { '{ "context": "Ping", "recipient": "SGMAP" }' }
  end

  factory :ping_report do
    uname { 'apie_2_etablissements' }
    last_code { 200 }
    first_downtime { '2017-11-28T00:00:14.836Z' }
  end
end
