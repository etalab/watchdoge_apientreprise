require 'rails_helper'

describe StatsController, type: :controller do
  context 'with jwt_usage action' do
    subject { get :jwt_usage, params: { jwt: jwt_api } }

    before { request.headers['Authorization'] = "Bearer #{jwt_session}" }

    context 'when jwt API & session are from the same user/UID' do
      # same UID
      let(:jwt_api)     { JwtHelper.api(:valid) }
      let(:jwt_session) { JwtHelper.session(:valid) }

      describe 'happy path (e2e spec)', vcr: { cassette_name: 'stats/jwt_usage' } do
        before { stub_jwt_usage_request }

        its(:status) { is_expected.to eq(200) }
        its(:body) { is_expected.to match_json_schema('stats/jwt_usage') }
      end

      describe 'when having an error', vcr: { cassette_name: 'stats/jwt_usage' } do
        before do
          stub_jwt_usage_request
          allow_any_instance_of(Stats::JwtUsageService).to receive(:success?).and_return(false)
        end

        its(:status) { is_expected.to eq(500) }
      end
    end

    describe 'when token returns 0 results', vcr: { cassette_name: 'stats/jwt_usage_empty_token' } do
      let(:jwt_api)     { JwtHelper.api(:valid) }
      let(:jwt_session) { JwtHelper.session(:valid) }

      before do
        allow_any_instance_of(described_class).to receive(:valid_jwt?).and_return(true)
        allow_any_instance_of(described_class).to receive(:jwt_of_user?).and_return(true)
      end

      its(:status) { is_expected.to eq(200) }
      its(:body) { is_expected.to match_json_schema('stats/jwt_usage') }
    end

    context 'when JWT API & session are from a different user/UID' do
      describe 'when jwt_session is admin', vcr: { cassette_name: 'stats/jwt_usage' } do
        let(:jwt_api)     { JwtHelper.api(:valid) }
        let(:jwt_session) { JwtHelper.session(:admin) }

        before { stub_jwt_usage_request }

        its(:status) { is_expected.to eq(200) }
        its(:body) { is_expected.to match_json_schema('stats/jwt_usage') }
      end

      describe 'when jwt_session is NOT admin', vcr: { cassette_name: 'stats/jwt_usage' } do
        let(:jwt_api)     { JwtHelper.api(:another_valid) }
        let(:jwt_session) { JwtHelper.session(:valid) }

        its(:status) { is_expected.to eq(403) }
        its(:body) { is_expected.to include_json(message: 'Cannot display someone else jwt usage without being an admin') }
      end
    end

    context 'when jwt param is BAD' do
      let(:jwt_session) { JwtHelper.session(:valid) }

      shared_examples 'invalid jwt param' do |jwt|
        let(:jwt_api) { jwt }

        its(:status) { is_expected.to eq(422) }
        its(:body)   { is_expected.to include_json(message: 'invalid jwt param') }
      end

      it_behaves_like 'invalid jwt param', 'invalid.jwt.param'
      it_behaves_like 'invalid jwt param', JwtHelper.api(:corrupted)
      it_behaves_like 'invalid jwt param', JwtHelper.api(:forged)

      describe 'when it is corrupted' do
        let(:jwt_api) { JwtHelper.api(:corrupted) }

        its(:status) { is_expected.to eq(422) }
        its(:body) { is_expected.to include_json(message: 'invalid jwt param') }
      end

      describe 'when it is forged' do
        let(:jwt_api) { JwtHelper.api(:forged) }

        its(:status) { is_expected.to eq(422) }
        its(:body) { is_expected.to include_json(message: 'invalid jwt param') }
      end
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
        allow_any_instance_of(Stats::Last30DaysUsageService).to receive(:success?).and_return(true)
        allow_any_instance_of(Stats::Last30DaysUsageService).to receive(:results).and_return(1_000_001)
      end

      its(:status) { is_expected.to eq(200) }
      its('body.to_i') { is_expected.to be > 1_000_000 }
    end

    context 'when having an error' do
      before { allow_any_instance_of(Stats::Last30DaysUsageService).to receive(:success?).and_return(false) }

      its(:status) { is_expected.to eq(500) }
    end
  end
end
