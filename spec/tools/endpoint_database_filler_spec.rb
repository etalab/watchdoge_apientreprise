require 'rails_helper.rb'

describe Tools::EndpointDatabaseFiller do
  subject(:filler) { described_class.instance }

  it { is_expected.to be_a(described_class) }

  describe 'when it fills the database with real data' do
    subject(:endpoints) { Endpoint.all }

    before { filler.refill_database }

    its(:count) { is_expected.to eq(endpoints_count) }

    it 'fills database with valid endpoints' do
      expect(endpoints.all).to all(be_valid)
    end

    it 'fills database with differents endpoints' do
      expect(endpoints.map(&:uname).count).to eq(endpoints_count)
      expect(endpoints.map(&:ping_url).count).to eq(endpoints_count)
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

    context 'when it is qualibat' do
      subject(:qualibat) { endpoints.first }

      it { is_expected.to be_valid }
      its(:uname) { is_expected.to eq('apie_2_certificats_qualibat') }
      its(:name) { is_expected.to eq('Certificat Qualibat') }
      its(:api_name) { is_expected.to eq('apie') }
      its(:api_version) { is_expected.to eq(2) }
      its(:provider) { is_expected.to eq('qualibat') }
      its(:ping_period) { is_expected.to eq(60) }
      its(:ping_url) { is_expected.to eq('/v2/certificats_qualibat/33592022900036') }

      it 'has a correct json_options' do
        expect(JSON.parse(qualibat.json_options)).to include_json(context: 'Ping', recipient: 'SGMAP')
      end
    end

    context 'when it is ProBTP' do
      subject(:probtp) { endpoints.second }

      it { is_expected.to be_valid }
      its(:uname) { is_expected.to eq('apie_1_eligibilites_cotisation_retraite_probtp') }
      its(:name) { is_expected.to eq('Eligibilité cotisations retraite ProBTP') }
      its(:api_name) { is_expected.to eq('apie') }
      its(:api_version) { is_expected.to eq(1) }
      its(:provider) { is_expected.to eq('probtp') }
      its(:ping_period) { is_expected.to eq(5) }
      its(:ping_url) { is_expected.to eq('/v1/eligibilites_cotisation_retraite_probtp/73582032600040') }

      it 'has a correct json_options' do
        expect(JSON.parse(probtp.json_options)).to include_json(context: 'Ping', recipient: 'SGMAP')
      end
    end
  end
end
