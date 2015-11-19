class ChartsController < ApplicationController
  def term_type
    types = Search.all.map{|s| s.term_type}.each_with_object(Hash.new(0)) { |tt,counts| counts[tt] += 1 }.sort_by{|tt,count| count}.reverse
    render :json => types
  end

  def sessions_dates
    s_d = Recoverysession.all.map { |e|  e.created_at.to_date}.each_with_object(Hash.new(0)) { |tt,counts| counts[tt] += 1 }.sort_by{|tt,count| count}
    render :json => s_d
  end
end
