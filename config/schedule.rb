# Learn more: http://github.com/javan/whenever
set :output, File.join(Whenever.path, 'log', 'watchdoge_cron.log')

# If you add a schedule make sure no endpoints are lost...
# all endpoints currently belongs to period 1, 5 or 60
every 1.minute do
  rake 'watch:period_1'
end

every 5.minutes do
  rake 'watch:period_5'
end

every 60.minutes do
  rake 'watch:period_60'
end
