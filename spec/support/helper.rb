def endpoints_count
  hash = YAML.load_file(subject.send(:endpoint_config_file))
  configfile_count = hash['endpoints'].count

  dir = 'app/models/endpoints'
  classfile_count = Dir[File.join(dir, '**', '*')].count { |file| File.file?(file) }

  configfile_count + classfile_count
end

def capture_output
  old_stdout = STDOUT.clone
  pipe_r, pipe_w = IO.pipe
  pipe_r.sync    = true
  output         = ""
  reader = Thread.new do
    begin
      loop do
        output << pipe_r.readpartial(1024)
      end
    rescue EOFError
    end
  end
  STDOUT.reopen(pipe_w)
  yield
ensure
  STDOUT.reopen(old_stdout)
  pipe_w.close
  reader.join
  return output
end
