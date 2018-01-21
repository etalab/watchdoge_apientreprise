require 'rails_helper'

describe AvailabilityHistory, type: :model do
  subject(:avail) { described_class.new }

  context 'when happy path' do
    it 'adds a new endpoint to list' do
      response = avail.aggregate(1, '2017-01-10 10:14:04')
      expect(response).to be_truthy
      expect(avail.to_a.size).to equal(1)
    end

    context 'with to_a' do
      before do
        avail.aggregate(1, '2017-01-10 10:14:04')
        avail.aggregate(1, '2017-01-10 10:17:04')
        avail.aggregate(0, '2017-01-11 10:14:04')
        avail.aggregate(0, '2017-01-11 10:14:08')
        avail.aggregate(0, '2017-01-12 10:14:04')
        avail.aggregate(1, '2017-01-13 20:14:04')
        avail.aggregate(1, '2017-01-20 20:14:08')
        avail.aggregate(0, '2017-01-20 20:14:10')
        avail.aggregate(1, '2017-01-20 20:15:04')
        avail.aggregate(0, '2017-01-20 20:15:10')
        avail.aggregate(1, '2017-01-20 20:16:04')
        avail.aggregate(1, '2017-01-25 20:17:04')
      end

      it 'matches json schema' do
        expect(avail.to_a).to match_json_schema('availability_history_model')
      end

      it 'has no gap and from < to' do
        expect(avail).to be_a_valid_availability_history
      end

      it 'compute correct sla' do
        expect(avail.sla).to eq(84.32)
      end
    end
  end

  describe 'error path' do
    it 'do not add when code is a string' do
      response = avail.aggregate('test', '2017-01-10 10:14:04')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add when code is 12' do
      response = avail.aggregate(12, '2017-01-10 10:14:04')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add wrong formated Time with /' do
      response = avail.aggregate(1, '2017/10/12 10:10:10')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add wrong formated Time with T separator' do
      response = avail.aggregate(1, '2017-10-12T10:10:10')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add wrong formated Time with timezone' do
      response = avail.aggregate(1, '2017-10-12 10:10:10.003Z')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end
  end
end
