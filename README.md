# FFCRM MetaSearch

Copyright (c) 2012 Global Hand, released under the MIT license.

Meta Search integration for Fat Free CRM provides Fat Free CRM controllers with the action 'meta_search' enabling complex queries. API authentication is required to call the action by implementing the 'require_application' method.

## Usage

* Include [ffcrm_meta_search](https://github.com/crossroads/ffcrm_meta_search) in your `Gemfile` for [ffcrm_app](https://github.com/fatfreecrm/ffcrm_app):

`gem 'ffcrm_meta_search',   :git => 'https://github.com/crossroads/ffcrm_meta_search.git'`

* Start your server

`rails s`
  
* Navigate to [http://localhost:3000/contacts/meta_search?only%5B%5D=id&only%5B%5D=name&only%5B%5D=email&search%5Balt_email_or_email_or_mobile_or_phone_cont%5D=12345678](http://localhost:3000/contacts/meta_search?only%5B%5D=id&only%5B%5D=name&only%5B%5D=email&search%5Balt_email_or_email_or_mobile_or_phone_cont%5D=12345678)

## Params

Specify the following params to configure the search:

* `:only => [:name, :email]` - will return name and email attributes in the results (note: id is always returned)
* `:alt_email_or_email_or_mobile_or_phone_cont => 12345678` - will search the email, alt_email, mobile and phone fields for 12345678. For more examples, see the [meta_search] https://github.com/ernie/meta_search.git) documentation.
* `api_key => 123123ASGEDF` - you will want to pass an api_key to authenticate.

## Tests

To run tests:

    rails db:test:prepare
    rspec spec/

The Gemfile.lock file references a fixed version of fat_free_crm, to ensure
you are testing against the most recent version, be sure to

`bundle update fat_free_crm`
  
before running your tests.
