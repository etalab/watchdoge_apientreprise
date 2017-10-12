# Learn more: http://github.com/javan/whenever
set :output, File.join(Whenever.path, "log", "watchdoge_cron.log")

every 5.minutes do
  rake 'watch:all'
end
