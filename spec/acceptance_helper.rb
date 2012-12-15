require_relative 'spec_helper'

require 'capybara'
require 'capybara/dsl'

Capybara.app = SimpleCodeReview

RSpec.configure { |c| c.include Capybara::DSL }