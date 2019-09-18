# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
ActiveResource::Base.logger = ActiveRecord::Base.logger

ENV['INLINEDIR'] = File.join(File.dirname(__FILE__),'../public/
uploads/')
