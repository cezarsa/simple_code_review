require 'rubygems'
require 'bundler'

Bundler.require
require 'sinatra/reloader'
require 'sinatra/static_assets'

require './server'
run SimpleCodeReview
