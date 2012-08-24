source :rubygems

gem 'bundler_local_development', :group => :development, :require => false
begin
  require 'bundler_local_development'
  Bundler.development_gems = ['fat_free_crm', /^ffcrm_/]
rescue LoadError
end

gemspec

gem 'fat_free_crm', :git => 'git://github.com/fatfreecrm/fat_free_crm.git', :ref => 'b5ddf8ee58a1a8ef532a8c634175e951716f7ca8'

group :test do
  gem 'pg'  # Default database for testing
  gem 'rspec'
  gem 'combustion'
  gem 'fuubar'
  gem 'ffaker'
  gem 'spork'
  if RUBY_VERSION.to_f >= 1.9
    gem 'factory_girl_rails', '~> 3.0.0'
  else
    gem 'factory_girl_rails', '~> 1.7.0'
  end
  unless ENV["CI"]
    gem 'ruby-debug',   :platform => :mri_18
    gem 'debugger',     :platform => :mri_19
    gem 'ci_reporter', '1.6.5'
  end
end
