FactoryBot.define do
  factory :endpoint do
    uname 'apie_2_certificats_qualibat'
    name 'Certificats Qualibat'
    api_name 'apie'
    api_version 2
    provider 'qualibat'
    ping_period 60
    ping_url '/v2/certificats_qualibat/33592022900036'
    json_options '{ "context": "Ping", "recipient": "SGMAP" }'
  end

  factory :ping_report do
    uname 'apie_2_etablissements'
    last_code 200
    first_downtime '2017-11-28T00:00:14.836Z'
  end
end
