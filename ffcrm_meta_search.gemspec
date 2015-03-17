# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'ffcrm_meta_search/version'

Gem::Specification.new do |s|
  s.name = 'ffcrm_meta_search'
  s.authors = ['Ben Tillman', 'Stephen Kenworthy']
  s.summary = 'Fat Free CRM - Meta Search'
  s.description = 'Fat Free CRM - Meta Search'
  s.files = `git ls-files`.split("\n")
  s.version = FatFreeCRM::MetaSearch::VERSION
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'fat_free_crm'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'ffaker', '~>1.0'
end
