module FfcrmMetaSearch
  class Engine < ::Rails::Engine

    config.to_prepare do
      require 'ffcrm_meta_search/controllers'
      AccountsController.include( FfcrmMetaSearch::Controllers )
      CampaignsController.include( FfcrmMetaSearch::Controllers )
      ContactsController.include( FfcrmMetaSearch::Controllers )
      LeadsController.include( FfcrmMetaSearch::Controllers )
      OpportunitiesController.include( FfcrmMetaSearch::Controllers )
      TasksController.include( FfcrmMetaSearch::Controllers )
    end

    config.generators do |g|
      g.test_framework      :rspec,       fixture: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

  end
end
