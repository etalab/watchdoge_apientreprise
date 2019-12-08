# Learn more: http://github.com/javan/whenever
set :output, File.join(Whenever.path, 'log', 'watchdoge_cron.log')

# Perfo infos:
# whenever can do the job of the rake task here
# BUT it will start one Rails instance of each endpoint
# so for every 60.minutes it will create 33 Rails instance
# this way there is only one Rails instance started on each schedule

# If you add a schedule make sure no endpoints are lost...
# all endpoints currently belongs to period 1, 5 or 60
every 1.minute do
  rake 'watch:period_1'
end

every 5.minutes do
  rake 'watch:period_5'
end

every 15.minutes do
  rake 'watch:period_15'
end

every 60.minutes do
  rake 'watch:period_60'
end

every 150.minutes do
  rake 'watch:period_150'
end
