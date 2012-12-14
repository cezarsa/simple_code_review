$stdout.sync = true

require 'resque/tasks'
require 'resque_scheduler/tasks'

task "resque:setup" do
  ENV['QUEUE'] = '*'

  require 'bundler'
  Bundler.require
  require 'resque/scheduler'

  Resque.schedule = YAML.load_file('config/jobs_schedule.yml')
  Mongoid.load!('config/mongoid.yml')

  require_relative 'jobs'
end
