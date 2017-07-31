def load_payload_files(filename)
  File.read(File.join(Rails.root, 'spec/support/payload_files', filename))
end
