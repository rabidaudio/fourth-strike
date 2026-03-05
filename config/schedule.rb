# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# The cron is set on the host outside of Docker
set :path, "/rails"
set :job_template, "cd /home/ubuntu/fourth-strike && docker compose run app ':job'"

every 8.hours do
  runner 'CurrencyUpdateJob.perform_later'
end

every 4.hours do
  runner 'CalculatorCache::Manager.recompute_all!'
end
