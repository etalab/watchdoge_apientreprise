require 'rails_helper'

describe StatsController, type: :controller do
  context 'with jwt_usage action' do
    subject { get :jwt_usage, params: { jti: jti } }

    describe 'happy path (e2e spec)', vcr: { cassette_name: 'stats/jwt_usage' } do
      let(:jti) { valid_jti }

      its(:status) { is_expected.to eq(200) }
      its(:body) { is_expected.to match_json_schema('stats/jwt_usage') }
    end

    describe 'when having an error', vcr: { cassette_name: 'stats/jwt_usage' } do
      let(:jti) { valid_jti }

      before { allow_any_instance_of(Stats::ApisUsageService).to receive(:success?).and_return(false) }

      its(:status) { is_expected.to eq(500) }
    end

    describe 'when token returns 0 results', vcr: { cassette_name: 'stats/jwt_usage_empty_token' } do
      let(:jti) { 'it_has_0_data' }

      its(:status) { is_expected.to eq(200) }
      its(:body) { is_expected.to match_json_schema('stats/jwt_usage') }
    end
  end

  context 'with last_30_days_usage action', vcr: { cassette_name: 'stats/last_30_days_usage' } do
    subject(:response) { get :last_30_days_usage }

    describe 'happy path (e2e)', vcr: { cassette_name: 'stats/last_30_days_usage' } do
      its(:status) { is_expected.to eq(200) }
      its('body.to_i') { is_expected.to be > 1_000_000 }
    end

    describe 'happy path (mocked)' do
      before do
        allow_any_instance_of(Stats::LastApiUsageService).to receive(:success?).and_return(true)
        allow_any_instance_of(Stats::LastApiUsageService).to receive(:results).and_return(1_000_001)
      end

      its(:status) { is_expected.to eq(200) }
      its('body.to_i') { is_expected.to be > 1_000_000 }
    end

    context 'when having an error' do
      before { allow_any_instance_of(Stats::LastApiUsageService).to receive(:success?).and_return(false) }

      its(:status) { is_expected.to eq(500) }
    end
  end

  describe '#last_year_usage', vcr: { cassette_name: 'stats/last_year_usage' } do
    subject(:response) { get :last_year_usage }

    describe 'happy path (e2e)', vcr: { cassette_name: 'stats/last_year_usage' } do
      its(:status) { is_expected.to eq 200 }
      its('body.to_i') { is_expected.to be > 20_000_000 }
    end

    describe 'happy path (mocked)' do
      before do
        allow_any_instance_of(Stats::LastApiUsageService).to receive(:success?).and_return(true)
        allow_any_instance_of(Stats::LastApiUsageService).to receive(:results).and_return(20_000_001)
      end

      its(:status) { is_expected.to eq(200) }
      its('body.to_i') { is_expected.to be > 20_000_000 }
    end

    context 'when having an error' do
      before { allow_any_instance_of(Stats::LastApiUsageService).to receive(:success?).and_return(false) }

      its(:status) { is_expected.to eq(500) }
    end
  end
end
