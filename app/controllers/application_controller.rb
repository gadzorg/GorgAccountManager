class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include ConfigurableEngine::ConfigurablesController

  after_filter :prepare_unobtrusive_flash
  private

  def after_sign_out_path_for(_resource_or_scope)
    Rails.application.secrets.cas_provider_url ? URI::join('https://',Rails.application.secrets.cas_provider_url,"/cas/logout?service=#{root_url}").to_s : root_url
  end
  
  rescue_from CanCan::AccessDenied, with: :access_denied

  private

    def access_denied(_exception)
      respond_to do |format|
        format.json { render nothing: true, status: :forbidden }
        format.html {
          store_location_for :user, request.fullpath
          if user_signed_in?
            render :file => "#{Rails.root}/public/403.html", :status => 403
          else
            redirect_to new_user_session_path
          end
        }
      end

    end
  

end
