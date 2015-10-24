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

		#ok bon on l'a trouvé, maintenant on liste ses adresses mail
		user_from_gram = GramAccount.find(@hruid)

		# TODO mettres des if not nil
		@list_emails = user_from_gram.mail_forwarding
		@list_emails.push(user_from_gram.mail_alias)
		@list_emails.push(user_from_gram.email)
		@list_emails.push(user_from_gram.email_forge)

		@list_emails = @list_emails.flatten.uniq

		#generation d'un token
		recovery_link = Uniqlink.new
		recovery_link.generate_token
		recovery_link.hruid = @hruid
		recovery_link.used = false
		recovery_link.expire_date = DateTime.now + 1.day # on definit la durée de vie d'un token à 1 jour
		recovery_link.save

		@r= recovery_link.get_url

		Recoverymailer.recovery_email("testemain@test.test", recovery_link.get_url, @hruid ).deliver_now


	end

	def password_reset
		token = params[:token]
		recovery_link = Uniqlink.find_by(token: token)
		@hruid = recovery_link.hruid

		@user = User.new
	end

	def password_change
		token = params[:token]
		recovery_link = Uniqlink.find_by(token: token)
		@hruid = recovery_link.hruid
		user_from_gram = GramAccount.find(@hruid)

		passwd_hash = Digest::SHA1.hexdigest params[:user][:password]
        user_from_gram.password = passwd_hash
        

        respond_to do |format|
        	if user_from_gram.save
	          format.html { redirect_to root_path, notice: 'mot de passe changé' }

        	else
	          format.html { redirect_to password_reset_path, notice: 'erreur lors de la maj du mot de passe' }
	
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
