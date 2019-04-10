source 'https://rubygems.org'

ruby '2.5.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 5.2.3'

#DATABASE
# Use sqlite3 as the database for Active Record
#gem 'sqlite3'
# Use mysql2 as the database for Active Record
#gem 'mysql2'
gem 'mysql2', '>= 0.3.20'

# Use 'foreigner' to add foreign_key constraints on database layer !
# https://github.com/matthuhiggins/foreigner
# gem 'foreigner'

# Use SCSS for stylesheets
gem 'sass-rails'
gem 'sassc', :git => "https://github.com/sass/sassc-ruby.git"
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'execjs'
gem 'therubyracer', :platforms => :ruby

#Documentation
gem 'annotate', '~> 2.6.6'

# Use jquery as the JavaScript library
gem 'jquery-validation-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Authentification
gem "omniauth-cas", :git => "https://github.com/gadzorg/omniauth-cas.git", :branch => 'saml'

# Authorisation
gem 'cancancan', '>= 1.16'

# API GRAM
gem 'activeresource'

gem 'email_validator'

# Templates
gem 'haml-rails', '= 1.0.0'

# Forms
gem 'simple_form'

#Autocompletion pour les form de recherche
gem 'rails4-autocomplete'

# i18n pour les conversion d'accents
gem 'i18n'

# better flash messaages
gem 'unobtrusive_flash', '>=3'

gem 'ruby-graphviz'

# tooltips
gem 'bootstrap-tooltip-rails'

# to avoid issue with protected attributes
gem 'safe_attributes'

# recapcha gem
gem "recaptcha",'~> 3.3' ,:require => "recaptcha/rails"

# pretty hash print in console
#gem 'awesome_print'

# charts
gem "chartkick"

# for inline css in mail
gem "premailer-rails"

gem 'nokogiri', '~> 1.6', '>= 1.7'

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

gem 'phonelib'

gem 'gorg_engine', git: 'https://github.com/gadzorg/GorgEngine.git'
gem 'simple_form-materialize', git: 'https://github.com/gadzorg/simple_form-materialize.git'
gem 'configurable_engine', git: 'https://github.com/gadzorg/configurable_engine.git'

gem "awesome_print", require:"ap"

group :production do
  #HEROKU
  gem 'heroku_secrets', git: 'https://github.com/gadzorg/heroku_secrets.git'
  gem 'rails_12factor'
  gem 'puma'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger consolep
  gem 'byebug'
  
  gem "letter_opener"


  #pour les diagramme UML
  gem 'rails-erd' 

  #better cli table view for db
  gem 'hirb' 

  # export db en yaml
  gem 'yaml_db', git: 'https://github.com/gadzorg/yaml_db.git'

  gem 'bogus'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rack-mini-profiler'
  # gem 'flamegraph'
  # gem 'stackprof' # ruby 2.1+ only
  # gem 'memory_profiler'
  # quiet_assets depend railties<5
  # gem 'quiet_assets'

end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  
  gem 'better_errors'
end


group :test do
  gem 'cucumber-rails', :require => false
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers', '~> 3.0'
  gem 'database_cleaner'
  gem 'webmock', '~> 2.1'
end

