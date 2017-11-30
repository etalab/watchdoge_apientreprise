def endpoints_count
  hash = YAML.load_file(subject.send(:endpoint_config_file))
  configfile_count = hash['endpoints'].count

  dir = 'app/models/endpoints'
  classfile_count = Dir[File.join(dir, '**', '*')].count { |file| File.file?(file) }

  configfile_count + classfile_count
end

def providers_count
  14
end

class FakeWorker
  def run(elements)
    elements.each do |e|
      yield e
    end
  end
end
