# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => Rails.application.secrets.smtp_user,
  :password => Rails.application.secrets.smtp_password,
  :domain => 'localhost',
  :address => Rails.application.secrets.smtp_adress,
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}
