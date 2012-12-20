ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
Bundler.setup

require 'simplecov'
SimpleCov.start

require 'omniauth'
require 'omniauth-github'
require 'mongoid'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/static_assets'
require 'factory_girl'
require 'database_cleaner'

require 'rack/test'
require_relative '../server'
require_relative 'factories'

module RSpecMixinExample
  include Rack::Test::Methods
  def app() SimpleCodeReview end
end

RSpec.configure { |c| c.include RSpecMixinExample }
RSpec.configure do |config|
  config.before :each do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end