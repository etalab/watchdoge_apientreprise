# Crono configuration file
#
# Here you can specify periodic jobs and schedule.
# You can use ActiveJob's jobs from `app/jobs/`
# You can use any class. The only requirement is that
# class should have a method `perform` without arguments.
#

Crono.perform(PingAPIEOnV2Job).every 5.minutes
# TODO: crono truncate table every ??
