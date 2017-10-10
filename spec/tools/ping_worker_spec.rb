describe Tools::PingWorker do
  it 'return all the elements' do
    elements = %w[test ok hello world mot doge le bon ordre]
    new_array = []
    Tools::PingWorker.new(elements, 3) do |element|
      new_array << element
    end

    expect(new_array).to include('test', 'ok', 'hello', 'world', 'mot', 'doge', 'le', 'bon', 'ordre')
  end
end
