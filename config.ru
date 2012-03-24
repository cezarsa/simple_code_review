require 'rubygems'
require 'bundler'

Bundler.require
require 'sinatra/reloader'

require './server'
run SimpleCodeReview