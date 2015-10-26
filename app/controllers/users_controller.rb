class UsersController < ApplicationController
	def recovery
		@user = User.new
		render :layout => 'recovery'
	end

	def create_recovery_session
		#on genere ici un token de session pour povoir tranmettre les info d'un page à une autre sans exposer l'hrui à l'utilisateur
		a = params[:user][:hruid].to_s
		respond_to do |format|
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
						#@hruid = "on t'as pas trouvé :-("
						
			    			format.html { redirect_to recovery_support_path() }
			    		
					end
				end

			end

			session = Recoverysession.new
			session.generate_token
			session.hruid = @hruid
			session.expire_date = DateTime.now + 15.minute # on definit la durée de vie d'un token à 15 minutes
			session.save

	    		format.html { redirect_to recovery_step1_path(:token_session => session.token) }
	    end

	end



	def recovery_step1
		@session_token = params[:token_session]
		session = Recoverysession.find_by(token: @session_token)

		if !session.nil? && session.usable?
			#on recupere l'utilisateur dans le site soce
			soce_user = Usersoce.where(hruid: session.hruid).take

			# cherche le numéro de téléhpone sur le site soce
			phone = soce_user.tel_mobile
			if !phone.nil?
				@phone_hidden = phone.gsub("."," ").split(//)[0..2].join + " xx xx xx " + phone.gsub("."," ").split(//).last(2).join
				@have_phone = true
			else
				@have_phone = false
			end


			render :layout => 'recovery'
		else
			respond_to do |format|
	    		format.html { redirect_to root_path, notice: 'Délais dépassé' }
	    	end
		end



	end


	def recovery_step2
		session_token = params[:token_session]
		# on recupère l'hruid à partir du token de session
		session = Recoverysession.find_by(token: session_token)
		@hruid = session.hruid

		#ok bon on l'a trouvé, maintenant on liste ses adresses mail
		user_from_gram = GramAccount.find(@hruid)

		#on recupere l'utilisateur dans le site soce
		soce_user = Usersoce.where(hruid: @hruid).take

		# TODO mettres des if not nil
		#emails du gram
		@list_emails = Array.new
		@list_emails.push(user_from_gram.mail_forwarding)
		#@list_emails.push(user_from_gram.mail_alias)
		@list_emails.push(user_from_gram.email)
		@list_emails.push(user_from_gram.email_forge)
		#email du site soce
		@list_emails.push(soce_user.emails_valides)

		@list_emails = @list_emails.flatten.uniq
		
		# on supprime les adresses en gadz.org pour éviter d'avoir des doublons
		# je l'ai commenté parce que les emails du gram ne sont pas forcement à jour
		#@list_emails = @list_emails.drop_while{|e| /gadz.org/.match(e)}

		@list_emails_to_display = @list_emails.map{|c|  /gadz/.match(c)? "Adresse @gadz.org": c[0]+c.gsub(/[A-Za-z0-9]/,"x")[1..c.length-3]+c[c.length-2..c.length-1]}


		#generation d'un token
		recovery_link = gen_uniq_link(@hruid)


		@r= recovery_link.get_url

		@list_emails.each do |email|	
			Recoverymailer.recovery_email(email, recovery_link.get_url, @hruid ).deliver_now
		end


		render :layout => 'recovery'

	end

	def password_reset
		token = params[:token]
		recovery_link = Uniqlink.find_by(token: token)
		if !recovery_link.nil? && recovery_link.usable?
			@hruid = recovery_link.hruid
			@user = User.new
			render :layout => 'recovery'
		else
	    	respond_to do |format|
	    		format.html { redirect_to root_path, notice: 'Ce lien a déjà été utilisé ou a expiré' }
	    	end
	    end
	end

	def password_change
		token = params[:token]
		recovery_link = Uniqlink.find_by(token: token)
		if recovery_link.usable?
			@hruid = recovery_link.hruid
			user_from_gram = GramAccount.find(@hruid)

			passwd_hash = Digest::SHA1.hexdigest params[:user][:password]
	        user_from_gram.password = passwd_hash
	        

	        respond_to do |format|
	        	if user_from_gram.save
	        	  # si on a reussi à changer le mdp, on mraue le lien comme utilisé
	        	  recovery_link.set_used
		          format.html { redirect_to recovery_final_path, notice: 'mot de passe changé' }

	        	else
		          format.html { redirect_to password_reset_path, notice: 'erreur lors de la maj du mot de passe', :layout => 'recovery'}
		
	        	end
	        end
	    else
	    	respond_to do |format|
	    		format.html { redirect_to root_path, notice: 'Ce lien a déjà été utilisé ou a expiré' }
	    	end
	    end
	end

	def create_sms
		session_token = params[:token_session]
		# on recupère l'hruid à partir du token de session
		session = Recoverysession.find_by(token: session_token)
		hruid = session.hruid

		#on genere un code pour le sms
		recovery_sms = Uniqsms.new
		recovery_sms.generate_token
		recovery_sms.hruid = hruid
		recovery_sms.used = false
		recovery_sms.expire_date = DateTime.now + 10.minute # on definit la durée de vie d'un token à 10 minutes
		recovery_sms.save

		#generation d'un token parce qu'on va en avoir besoin 
		# quand on sera redirigé sur la pase de changement de mdp
		recovery_link = gen_uniq_link(hruid)

		#ici code envoi sms

		respond_to do |format|
	    	format.html { redirect_to recovery_sms_path(:token_session => session_token) }
	    end
	end

	def validate_sms
		#on récupere le mini token du sms et si il est bon, 
		#on prend le token du mail pour aller à la page de changement de mdp
		token_sms = params[:token]
		token_session = params[:token_session]
		sms_uniq = Uniqsms.find_by(token: token_sms)
		session = Recoverysession.find_by(token: token_session)

		respond_to do |format|
			if !sms_uniq.nil? && sms_uniq.usable? && !session.nil? && session.usable?
				if sms_uniq.check_count < 4 #nombre max de verifications add_check ajoute et renvoie le nombre de verif
					hruid = sms_uniq.hruid
					token = Uniqlink.where(hruid: hruid).where(used: false).last.token
					sms_uniq.set_used
					sms_uniq.save

				
		    		format.html { redirect_to password_change_path(:token => token) }
		    	else
		    		# nombre max de verif atteint
		    		format.html { redirect_to recovery_path(), alert: 'Nombre maximum de tentatives atteint ' }
		    	end
		    else
		    	session.add_sms_check
		    	# code invalide
		    	format.html { redirect_to recovery_sms_path(:token_session => token_session), alert: 'Code invalide' }
		    end
	    end


	end
	def recovery_sms
		session_token = params[:token_session]
		# on recupère l'hruid à partir du token de session
		session = Recoverysession.find_by(token: session_token)
		@hruid = session.hruid
		@session_token = session_token

		#on recupere l'utilisateur dans le site soce
		soce_user = Usersoce.where(hruid: @hruid).take
		phone = soce_user.tel_mobile
		@phone_hidden = phone.gsub("."," ").split(//)[0..2].join + " xx xx xx " + phone.gsub("."," ").split(//).last(2).join

		render :layout => 'recovery'
	end

	def recovery_final
		render :layout => 'recovery'
	end
	def recovery_support
		@user = User.new
		render :layout => 'recovery'
	end

	def recovery_support_mail
		#TODO template mail
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

	    def gen_uniq_link(hruid)
		    recovery_link = Uniqlink.new
			recovery_link.generate_token
			recovery_link.hruid = hruid
			recovery_link.used = false
			recovery_link.expire_date = DateTime.now + 1.day # on definit la durée de vie d'un token à 1 jour
			recovery_link.save
			return recovery_link
	    end

end
