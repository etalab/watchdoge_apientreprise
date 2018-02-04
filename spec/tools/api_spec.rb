require 'rails_helper'

describe Tools::API do
  subject { described_class.new(api_name: api_name, api_version: api_version) }

  describe 'sirene' do
    let(:api_name) { 'sirene' }
    let(:api_version) { 1 }

    its(:base_url) { is_expected.to match(/sirene.entreprise.api.gouv.fr/) }
    its(:token) { is_expected.to be_nil }
  end

  describe 'api entreprise' do
    let(:api_name) { 'apie' }

    describe 'api version = 1' do
      let(:api_version) { 1 }

      its(:base_url) { is_expected.to match(/apientreprise.fr/) }
      its(:token) { is_expected.not_to be_nil }
    end

    describe 'api version = 2' do
      let(:api_version) { 2 }

      its(:base_url) { is_expected.to match(/entreprise.api.gouv.fr/) }
      its(:token) { is_expected.not_to be_nil }
    end
  end
end
