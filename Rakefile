$stdout.sync = true

require 'resque/tasks'
require 'resque_scheduler/tasks'
require 'rspec/core'
require 'rspec/core/rake_task'

task :default => :spec

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec)

task "resque:setup" do
  ENV['QUEUE'] = '*'

  require 'bundler'
  Bundler.require
  require 'resque/scheduler'

  Resque.schedule = YAML.load_file('config/jobs_schedule.yml')
  Mongoid.load!('config/mongoid.yml')

  require_relative 'jobs'
end
