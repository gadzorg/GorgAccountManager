source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>4.2'

#DATABASE
# Use sqlite3 as the database for Active Record
#gem 'sqlite3'
# Use mysql2 as the database for Active Record
#gem 'mysql2'
gem 'mysql2', '~> 0.3.20'

# Use 'foreigner' to add foreign_key constraints on database layer !
# https://github.com/matthuhiggins/foreigner
# gem 'foreigner'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'execjs'
gem 'therubyracer', :platforms => :ruby

#Documentation
gem 'annotate', '~> 2.6.6'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-validation-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Authentification
gem 'devise', '~> 3.5.10'
gem 'omniauth'
gem "omniauth-cas", :git => "https://github.com/loocla/omniauth-cas.git", :branch => 'saml'

# Authorisation
gem 'cancancan'

# API GRAM
gem 'activeresource'

gem 'email_validator'

# Templates
gem 'haml-rails'

# Forms
gem 'simple_form'

# Pagination
gem 'will_paginate', '~> 3.0.0'

#Autocompletion pour les form de recherche
gem 'rails4-autocomplete'

# i18n pour les conversion d'accents
gem 'i18n'

# better flash messaages
gem 'unobtrusive_flash', '>=3'

# forconfiguration tables
gem 'configurable_engine'

# tooltips
gem 'bootstrap-tooltip-rails'

# to avoid issue with protected attributes
gem 'safe_attributes'

# recapcha gem
gem "recaptcha", :require => "recaptcha/rails"

# pretty hash print in console
gem 'awesome_print'

# charts
gem "chartkick"

# for inline css in mail
gem "premailer-rails"

gem "nokogiri"

gem "geocoder", "~> 1.3.7"

gem "fuzzy-string-match"

# Gadz.org Gems Gram v2 client
gem 'gram_v2_client', git: 'https://github.com/gadzorg/gram2_api_client_ruby.git'

#gem "linkedin-scraper"

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger consolep
  gem 'byebug'
  
  gem "letter_opener"


  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'


  #pour les diagramme UML
  gem 'rails-erd' 

  #better cli table view for db
  gem 'hirb' 

  # export db en yaml
  gem 'yaml_db', github: 'jetthoughts/yaml_db', ref: 'fb4b6bd7e12de3cffa93e0a298a1e5253d7e92ba'

  gem 'rspec-rails'

  #performance test
  gem 'rack-mini-profiler'
  # gem 'flamegraph'
  # gem 'stackprof' # ruby 2.1+ only
  # gem 'memory_profiler'
  gem 'quiet_assets'

end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  
  gem 'better_errors'
end


group :test do
  gem 'faker'
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers', '~> 3.0'
end
