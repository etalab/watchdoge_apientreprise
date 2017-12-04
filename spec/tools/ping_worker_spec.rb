require 'rails_helper.rb'

describe Tools::PingWorker do
  subject { described_class.new }

  let(:elements) { %w[test ok hello world mot doge le bon ordre] }
  let(:new_array) { [] }

  before do
    subject.run(elements, 3) do |element|
      new_array << element
    end
  end

  it 'return all the elements' do
    expect(new_array).to include('test', 'ok', 'hello', 'world', 'mot', 'doge', 'le', 'bon', 'ordre')
  end
end
