class StaticPagesController < ApplicationController
  before_action :set_user, only:[:index]
  def index
  	# render :layout => 'landing'
  end

  private
    def set_user
      @user = current_user
    end
end
