module FatFreeCRM
  module MetaSearch
    class Engine < Rails::Engine
      config.to_prepare do
        require 'ffcrm_meta_search/controllers'
      end
    end
  end
end
