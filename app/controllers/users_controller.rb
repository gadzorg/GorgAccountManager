class UsersController < ApplicationController
	def recovery
		@user = User.new
	end

	def recovery_step2
		a = params[:user][:hruid].to_s

		#on cherche si ce qui est rentré dans le formulaire est un email, hrui ou num soce via l'api GrAM
		begin
			@hruid = GramEmail.find(a).hruid
		rescue ArgumentError ||  ActiveResource::ResourceNotFound
			begin
				@hruid = GramAccount.find(a).hruid
			rescue ActiveResource::ResourceNotFound || ArgumentError
				begin
					@hruid = GramSearch.where(:idSoce => a.gsub(/[a-zA-Z]/,'')).first.hruid
				rescue ActiveResource::ServerError
					@hruid = "on t'as pas trouvé :-("
				end
			end

		end

		#ok bon on l'a trouve, maintenant on liste ses adresses mail
		user_from_gram = GramAccount.find(@hruid)

		# TODO mettres des if not nil
		@list_emails = user_from_gram.mail_forwarding
		@list_emails.push(user_from_gram.mail_alias)
		@list_emails.push(user_from_gram.email)
		@list_emails.push(user_from_gram.email_forge)

		@list_emails = @list_emails.flatten.uniq


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
