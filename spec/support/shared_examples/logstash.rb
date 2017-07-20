RSpec.shared_examples 'logstashed_ping' do
  subject { described_class.new }

  it 'writes in file in logstash format' do
    value = 'this is a value'
    another_value = 'this is another value'
    subject.logger.info({
      rspec: value,
      another_rspec: another_value
    })

    filename = described_class.send(:logfile)
    last_line = File.readlines(filename).last
    json = JSON.parse(last_line, symbolize_keys: true)

    expect(json).to include_json(
      msg: 'ping',
      rspec: value,
      another_rspec: another_value
    )

    File.truncate(filename, 0)
  end
end
