require 'rails_helper'

describe Dashboard::HomepageStatusElastic, type: :service do
  describe 'response', vcr: { cassette_name: 'homepage_status' } do
    subject { described_class.new.get }

    its(:success?) { is_expected.to be_truthy }
  end

  describe 'results', vcr: { cassette_name: 'homepage_status' } do
    subject { service.results }

    let(:service) { described_class.new.get }

    its(:size) { is_expected.to equal(1) }

    describe 'first element' do
      subject { service.results.dig(0) }

      its(['name']) { is_expected.not_to be_empty }
      its(['code']) { is_expected.to be_a(Integer) }
      its(['code']) { is_expected.to be_between(200, 599) }
      its(['timestamp']) { is_expected.to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[A-Z]/) }
    end
  end
end
