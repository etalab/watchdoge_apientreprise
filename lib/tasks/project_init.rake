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
    content = watchdoge_secrets
    file = File.new('config/watchdoge_secrets.yml', 'w+')
    file.write(content.unindent)
  end

  def init_database
    Rake::Task['db:create:all'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:prepare'].invoke
  end
end

def watchdoge_secrets
  <<EOF
    defaults: &DEFAULTS
      apie_token: such_token

    development:
      <<: *DEFAULTS
    test:
      <<: *DEFAULTS
EOF
end
