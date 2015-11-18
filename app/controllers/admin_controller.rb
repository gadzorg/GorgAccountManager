class AdminController < ApplicationController
  
  def index
    authorize! :read, :admin
  end

  def stats
    @links_count = Uniqlink.all.count
    @sessions_count = Recoverysession.all.count
    @sms_count = Uniqsms.all.count
  end
end
