module FatFreeCRM
  module MetaSearch
    class Engine < Rails::Engine
      config.to_prepare do
        require 'ffcrm_meta_search/controllers'
      end

      # tell Rails when generating models, controllers, etc. for this engine
      # to use RSpec and FactoryGirl, instead of the default of Test::Unit and fixtures
      config.generators do |g|
        g.test_framework      :rspec,        :fixture => false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.assets false
        g.helper false
      end

    end
  end
end
