require 'rubygems'
require 'spork'

Spork.prefork do
  require 'bundler'
  require 'rails/all'

  Bundler.require :default, :development

  # Load factories
  require 'factory_girl'
  require 'ffaker'
  Dir[Rails.root.join("spec/factories/*.rb")].each{ |f| require File.expand_path(f) }

  Combustion.initialize!
  
  # Reload User model after schema is loaded,
  # so that Authlogic detects password fields
  load 'user.rb'

  require 'rspec/rails'

  require 'rspec/autorun'

  RSpec.configure do |config|
    config.use_transactional_fixtures = true
  end
end
