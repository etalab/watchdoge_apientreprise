require 'rails_helper.rb'

describe Tools::PingWorker do
  subject { described_class.new }
  it 'return all the elements' do
    elements = %w[test ok hello world mot doge le bon ordre]
    new_array = []
    subject.run(elements, 3) do |element|
      new_array << element
    end

    expect(new_array).to include('test', 'ok', 'hello', 'world', 'mot', 'doge', 'le', 'bon', 'ordre')
  end
end
