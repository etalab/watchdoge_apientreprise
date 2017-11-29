require 'rails_helper.rb'

describe Availabilities, type: :model do
  subject(:avail) { described_class.new }

  let(:datetime1) { '2017-01-10 10:14:04' }
  let(:datetime2) { '2017-01-10 10:17:04' }
  let(:datetime3) { '2017-01-11 10:14:04' }
  let(:datetime4) { '2017-01-11 10:14:08' }
  let(:datetime5) { '2017-01-20 10:14:04' }
  let(:datetime6) { '2017-01-20 20:14:04' }

  context 'happy path' do
    it 'adds a new endpoint to list' do
      response = avail.add_history(1, datetime1)
      expect(response).to be_truthy
      expect(avail.to_a.size).to equal(1)
    end

    context 'to_a method return the right data' do
      before do
        avail.add_history(1, datetime1)
        avail.add_history(1, datetime2)
        avail.add_history(0, datetime3)
        avail.add_history(0, datetime4)
        avail.add_history(0, datetime5)
        avail.add_history(1, datetime6)
      end

      it 'is an array of arrays' do
        avail_array = avail.to_a
        expect(avail_array).to be_a(Array)
        avail_array.each do |e|
          expect(e).to be_a(Array)
          expect(e.size).to equal(3)
        end
      end

      it 'has coherent data inside' do
        avail.to_a.each do |e|
          from = DateTime.parse(e[0])
          to = DateTime.parse(e[2])

          expect(e[0]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
          expect(e[2]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
          expect(to).to be >= from

          expect(e[1]).to be_in([0, 1])
        end
      end

      it 'compute correct sla' do
        expect(avail.sla).to eq(13.61)
      end
    end
  end

  describe 'error path' do
    it 'do not add when code is not 1 or 0' do
      response = avail.add_history('test', datetime1)
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add when code is not 1 or 0' do
      response = avail.add_history(12, datetime1)
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add wrong formated datetime with /' do
      response = avail.add_history(1, '2017/10/12 10:10:10')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add wrong formated datetime with T separator' do
      response = avail.add_history(1, '2017-10-12T10:10:10')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end

    it 'do not add wrong formated datetime with timezone' do
      response = avail.add_history(1, '2017-10-12 10:10:10.003Z')
      expect(response).to be_falsey
      expect(avail.to_a.size).to equal(0)
    end
  end
end
