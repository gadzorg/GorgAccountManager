source "https://rubygems.org"

ruby File.read(".ruby-version").strip

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "5.0.7.2"

#DATABASE

# Use mysql2 as the database for Active Record
gem "mysql2"

# Use 'foreigner' to add foreign_key constraints on database layer !
# https://github.com/matthuhiggins/foreigner
# gem 'foreigner'

# Use SCSS for stylesheets
gem "sass-rails"
gem "materialize-sass", "< 1"

# Use Uglifier as compressor for JavaScript assets
gem "uglifier"

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem "execjs"
gem "mini_racer"

#Documentation
gem "annotate"

# Use jquery as the JavaScript library
gem "jquery-validation-rails"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder"
# bundle exec rake doc:rails generates the API under doc/api.
gem "sdoc", group: :doc

# Authentification
gem "devise"
gem "omniauth-cas",
    git: "https://github.com/loocla/omniauth-cas.git", branch: "saml"

# Authorisation
gem "cancancan"

# API GRAM
gem "activeresource"

gem "email_validator"

# Templates
gem "haml-rails"

# Forms
gem "simple_form"

#Autocompletion pour les form de recherche
gem "rails4-autocomplete"

# i18n pour les conversion d'accents
gem "i18n"

# better flash messaages
gem "unobtrusive_flash"

# tooltips
gem "bootstrap-tooltip-rails"

# to avoid issue with protected attributes
gem "safe_attributes"

# recapcha gem
gem "recaptcha", require: "recaptcha/rails"

# charts
gem "chartkick"

# for inline css in mail
gem "premailer-rails"

gem "nokogiri"

gem "geocoder"

gem "fuzzy-string-match"

# Gadz.org Gems Gram v2 client
gem "gram_v2_client",
    git: "https://github.com/gadzorg/gram2_api_client_ruby", ref: "4425fa6"

#gem "linkedin-scraper"

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "phonelib"

gem "gorg_engine", git: "https://github.com/gadzorg/GorgEngine", ref: "v2.0.0"
gem "configurable_engine",
    git: "https://github.com/gadzorg/configurable_engine"

group :production do
  #HEROKU
  gem "heroku_secrets", git: "https://github.com/alexpeattie/heroku_secrets"
  gem "rails_12factor"
  gem "puma"
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger consolep
  gem "pry-byebug"
  gem "pry-rails"

  gem "letter_opener"

  #pour les diagramme UML
  gem "rails-erd"

  #better cli table view for db
  gem "hirb"

  # export db en yaml
  gem "yaml_db", git: "https://github.com/gadzorg/yaml_db"

  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rack-mini-profiler", require: false
  # gem 'flamegraph'
  # gem 'stackprof' # ruby 2.1+ only
  # gem 'memory_profiler'

  # pretty hash print in console
  gem "awesome_print"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console"

  gem "better_errors"
  gem "binding_of_caller"
end

group :test do
  gem "cucumber-rails", require: false
  gem "capybara"
  gem "launchy"
  gem "shoulda-matchers"
  gem "database_cleaner"
  gem "webmock"

  gem "simplecov"

  gem "rails-controller-testing"
end
