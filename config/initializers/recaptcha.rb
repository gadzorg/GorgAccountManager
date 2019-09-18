Recaptcha.configure do |config|
  config.site_key = Rails.application.secrets.recaptcha_site_key
  config.secret_key = Rails.application.secrets.recaptcha_secret_key
  unless Rails.application.secrets.proxy.nil?
    config.proxy = Rails.application.secrets.proxy
  end
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
  # Uncomment if you want to use the newer version of the API,
  # only works for versions >= 0.3.7:
  # config.api_version = 'v2'
end
