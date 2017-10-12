# Learn more: http://github.com/javan/whenever
set :output, File.join(Whenever.path, "log", "watchdoge_cron.log")

every 5.minutes do
  rake 'apie_v1:all'
  rake 'apie_v2:all'
end
