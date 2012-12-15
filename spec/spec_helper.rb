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

require 'rack/test'
require_relative '../server'

module RSpecMixinExample
  include Rack::Test::Methods
  def app() SimpleCodeReview end
end

RSpec.configure { |c| c.include RSpecMixinExample }
