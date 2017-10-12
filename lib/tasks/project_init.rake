require 'fileutils'

namespace :dev do
  desc 'initialize dev environment'
  task :init do
    puts 'Start initialization'.green
    create_secrets
    init_database
  end

  def create_secrets
    puts 'create dummy Watchdoge secrets'.green
    content = secrets
    file = File.new('config/secrets.yml', 'w+')
    file.write(content.unindent)
  end

  def init_database
    Rake::Task['db:create:all'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:prepare'].invoke
  end
end

def secrets
  <<EOF
    defaults: &DEFAULTS
      apie_token: such_token
      apie_base_uri: 'api-sandbox.apientreprise.fr'
      secret_key_base: 41b60bfad06bbcf0262cb68aa77ddb9fc56d9a39a2591dd32a7d3be5724ed4fb10a20f408b6dcc7f66bfc6b8fa8eaf39b0e4eff77003e2e9db51a794c84b5d8e

    sandbox:
      <<: *DEFAULTS
    development:
      <<: *DEFAULTS
    test:
      <<: *DEFAULTS
    production:
      <<: *DEFAULTS
EOF
end
