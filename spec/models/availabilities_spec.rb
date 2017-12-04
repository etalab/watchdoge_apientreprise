require 'rails_helper.rb'

describe Availabilities, type: :model do
  subject(:avail) { described_class.new }

  context 'when happy path' do
    it 'adds a new endpoint to list' do
      response = avail.add_ping(1, '2017-01-10 10:14:04')
      expect(response).to be_truthy
      expect(avail.to_a.size).to equal(1)
    end

    context 'with to_a' do
      before do
        avail.add_ping(1, '2017-01-10 10:14:04')
        avail.add_ping(1, '2017-01-10 10:17:04')
        avail.add_ping(0, '2017-01-11 10:14:04')
        avail.add_ping(0, '2017-01-11 10:14:08')
        avail.add_ping(0, '2017-01-12 10:14:04')
        avail.add_ping(1, '2017-01-13 20:14:04')
        avail.add_ping(1, '2017-01-20 20:14:08')
        avail.add_ping(0, '2017-01-20 20:14:10')
        avail.add_ping(1, '2017-01-20 20:15:04')
        avail.add_ping(0, '2017-01-20 20:15:10')
        avail.add_ping(1, '2017-01-20 20:16:04')
        avail.add_ping(1, '2017-01-25 20:17:04')
      end

      it 'matches json schema' do
        expect(avail.to_a).to match_json_schema('availabilities')
      end

      it 'has no gap and from < to' do
        previous_to_datetime = nil
        avail.to_a.each do |a|
          # from < to
          expect(DateTime.parse(a[0])).to be < DateTime.parse(a[2])

          # has no gap
          unless previous_to_datetime.nil?
            from_datetime = DateTime.parse(a[0])
            expect(from_datetime).to eq(previous_to_datetime)
          end

          previous_to_datetime = DateTime.parse(a[2])
        end
      end

      it 'compute correct sla' do
        expect(avail.sla).to eq(84.32)
      end
    end
  end

  describe 'error path' do
    it 'do not add when code is not 1 or 0' do
      response = avail.add_ping('test', '2017-01-10 10:14:04')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add when code is not 1 or 0' do
      response = avail.add_ping(12, '2017-01-10 10:14:04')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add wrong formated datetime with /' do
      response = avail.add_ping(1, '2017/10/12 10:10:10')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add wrong formated datetime with T separator' do
      response = avail.add_ping(1, '2017-10-12T10:10:10')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add wrong formated datetime with timezone' do
      response = avail.add_ping(1, '2017-10-12 10:10:10.003Z')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end
  end
end
