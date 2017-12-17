require 'rails_helper.rb'

describe Tools::EndpointDatabaseFiller do
  subject(:filler) { described_class.instance }

  it { is_expected.to be_a(described_class) }

  describe 'when it fills the database with real data' do
    subject(:endpoints) { Endpoint.all }

    before { filler.refill_database }

    its(:count) { is_expected.to eq(40) }

    it 'fills correctly the database' do
      endpoints.each do |ep|
        expect(ep).to be_valid
      end
    end
  end

  it 'empties the database' do
    create(:endpoint)
    expect(Endpoint.all.count).to eq(1)
    allow(filler).to receive(:fill_database).and_return(nil)
    filler.refill_database
    expect(Endpoint.all.count).to eq(0)
  end

  describe 'refill with payload file' do
    subject(:endpoints) { Endpoint.all }

    before do
      allow(filler).to receive(:endpoints_config_file).and_return('spec/support/payload_files/endpoints.yml')
      filler.refill_database
    end

    its(:count) { is_expected.to eq(2) }

    it 'has qualibat v2 endpoint' do
      qualibat = endpoints.first
      expect(qualibat).to be_valid
      expect(qualibat.uname).to eq('apie_2_certificats_qualibat')
      expect(qualibat.name).to eq('Certificat Qualibat')
      expect(qualibat.api_name).to eq('apie')
      expect(qualibat.api_version).to eq(2)
      expect(qualibat.provider).to eq('qualibat')
      expect(qualibat.ping_period).to eq(60)
      expect(qualibat.ping_url).to eq('/v2/certificats_qualibat/33592022900036')
      expect(JSON.parse(qualibat.json_options)).to include_json(context: 'Ping', recipient: 'SGMAP')
    end

    it 'has ProBTP v2 endpoint' do
      probtp = endpoints.second
      expect(probtp).to be_valid
      expect(probtp.uname).to eq('apie_1_eligibilites_cotisation_retraite_probtp')
      expect(probtp.name).to eq('Eligibilité cotisations retraite ProBTP')
      expect(probtp.api_name).to eq('apie')
      expect(probtp.api_version).to eq(1)
      expect(probtp.provider).to eq('probtp')
      expect(probtp.ping_period).to eq(5)
      expect(probtp.ping_url).to eq('/v1/eligibilites_cotisation_retraite_probtp/73582032600040')
      expect(JSON.parse(probtp.json_options)).to include_json(context: 'Ping', recipient: 'SGMAP')
    end
  end
end
