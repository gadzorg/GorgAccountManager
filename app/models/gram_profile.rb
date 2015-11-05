#/lib/GramAccount.rb
#!/bin/env ruby
# encoding: utf-8

require 'active_resource'
class GramProfile < ActiveResource::Base
  self.element_name = "profiles"
  self.site = Rails.application.secrets.gram_api_site
  self.user = Rails.application.secrets.gram_api_user
  self.password = Rails.application.secrets.gram_api_password
  unless Rails.application.secrets.proxy
    self.proxy = Rails.application.secrets.proxy
  end


  #Overwrite find_single from ActiveResource::Base to be able to use gram api (/accounts suffix)
  #https://github.com/rails/activeresource/blob/master/lib/active_resource/base.rb#L991
  def self.element_path(id, prefix_options = {}, query_options = nil)
     id += "/profile"
     super(id, prefix_options, query_options)
  end

  #Overwrite to_param from ActiveResource::Base to be able to use gram api (id = hruid)
  #https://github.com/rails/activeresource/blob/master/lib/active_resource/base.rb#L991
  def to_param
    self.hruid
  end

end

