class UsersController < ApplicationController
	def recovery
		@user = User.new
	end

	def recovery_step2
		a = params[:user][:hruid].to_s
		begin
			@data = GramEmail.find(a).hruid
		rescue ArgumentError ||  ActiveResource::ResourceNotFound
			begin
				@data = GramAccount.find(a).hruid
			rescue ActiveResource::ResourceNotFound || ArgumentError
				begin
					@data = GramSearch.where(:idSoce => a).first.hruid
				rescue ActiveResource::ServerError
					@data = "on t'as pas trouvé :-("
				end
			end

		end
	end

    
	private
		    # Use callbacks to share common setup or constraints between actions.
	    def set_user
	      @user =(params[:id] ?  User.find(params[:id]) : current_user)
	    end
	    # Never trust parameters from the scary internet, only allow the white list through.
		def user_params_pub
	      params[:user].permit(:hruid)
	    end

end
