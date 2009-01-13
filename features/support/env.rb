# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
ENV['RAILS_ROOT'] = File.join(File.dirname(__FILE__),'..','..','..','..','..')

require File.expand_path(ENV['RAILS_ROOT'] + '/config/environment')
require 'cucumber/rails/world'
require 'cucumber/formatters/unicode' # Comment out this line if you don't want Cucumber Unicode support
Cucumber::Rails.use_transactional_fixtures

require 'webrat/rails'

# Comment out the next two lines if you're not using RSpec's matchers (should / should_not) in your steps.
require 'cucumber/rails/rspec'
require 'webrat/rspec-rails'
