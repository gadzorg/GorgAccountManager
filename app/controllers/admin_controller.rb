class AdminController < ApplicationController
  
  def index
    authorize! :read, :admin
  end

  def stats
    authorize! :read, :admin
    @links_count = Uniqlink.all.count
    @sessions_count = Recoverysession.all.count
    @sms_count = Uniqsms.all.count

    @top_hruid = Recoverysession.all.map{|r| r.hruid}.each_with_object(Hash.new(0)) { |hruid,counts| counts[hruid] += 1 }.sort_by{|hruid,count| count}.reverse.take(10)
  end
end
