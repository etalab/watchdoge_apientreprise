require 'rails_helper'

describe Stats::LastCallsService, type: :services, vcr: { cassette_name: 'stats/last_calls' } do
  subject { described_class.new(jti: valid_jti).tap(&:perform) }

  its(:success?) { is_expected.to be_truthy }
  its(:results) { is_expected.to match_json_schema 'stats/last_calls' }
end
