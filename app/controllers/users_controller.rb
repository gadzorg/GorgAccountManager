class UsersController < ApplicationController
	require 'net/http'
	before_action :set_user, only: [:show, :edit, :update, :destroy, :dashboard, :flag  ]
  	autocomplete :user, :hruid , :full => true, :display_value =>:hruid, extra_data: [:id, :firstname ] #, :scopes => [:search_by_name]

# GET /users
  # GET /users.json
  def index
  	@users = User.accessible_by(current_ability)
  	authorize! :read, User
  end

  # GET /users/1
  # GET /users/1.json
  def show
  	authorize! :read, @user
  end

  # GET /users/new
  def new
  	@user = User.new
  	authorize! :create, @user
  	@roles=Role.accessible_by(current_ability)
  end

  # GET /users/1/edit
  def edit
  	authorize! :update, @user
  	@roles=Role.accessible_by(current_ability)
  end

  # POST /users
  # POST /users.json
  def create
  	@user = User.new(user_params)
  	authorize! :create, @user
  	authorize! :update, (user_params[:role_id].present? ? Role.find(user_params[:role_id]) : Role)

  	respond_to do |format|
  		if @user.save
  			format.html { redirect_to @user, notice: 'User was successfully created.' }
  			format.json { render :show, status: :created, location: @user }
  		else
  			format.html { render :new }
  			format.json { render json: @user.errors, status: :unprocessable_entity }
  		end
  	end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
  	authorize! :update, @user
  	authorize! :update, (user_params[:role_id].present? ? Role.find(user_params[:role_id]) : Role)

  	respond_to do |format|
  		if @user.update(user_params)
  			format.html { redirect_to @user, notice: 'User was successfully updated.' }
  			format.json { render :show, status: :ok, location: @user }
  		else
  			format.html { render :edit }
  			format.json { render json: @user.errors, status: :unprocessable_entity }
  		end
  	end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
  	authorize! :destroy, @user
  	@user.destroy
  	respond_to do |format|
  		format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
  		format.json { head :no_content }
  	end
  end


  def search_by_id
  	redirect_to user_path(params[:id])
  end

  def recovery
  	@user = User.new
		re_try = params[:retry] #true si on vient d'écoucher. la page est appellée en POST

		if !re_try.nil? || re_try == true 
			@first_attempt = false
		else
			@first_attempt = true
		end	 		
		render :layout => 'recovery'
	end

	def create_recovery_session
		#on genere ici un token de session pour povoir tranmettre les info d'un page à une autre sans exposer l'hrui à l'utilisateur
		a = params[:user][:hruid].to_s
		#on enregistre les recherches pour les stats
		search = Search.new(term: a)
		respond_to do |format|

			if !a.nil? && a != "" # on verifie si la recherche n'est pas vide
				if verify_recaptcha
				#on cherche si ce qui est rentré dans le formulaire est un email, hrui ou num soce via l'api GrAM
				begin
					@hruid = GramEmail.find(a).hruid
					search.term_type = "Email GrAM"
					search.save
					rescue #ArgumentError ||  ActiveResource::ResourceNotFound
						begin
							@hruid = GramAccount.find(a).hruid
							search.term_type = "Hruid"
							search.save
						rescue #ActiveResource::ResourceNotFound || ArgumentError
							begin
								@hruid = GramSearch.where(:idSoce => a.gsub(/[a-zA-Z]/,'')).first.hruid
								search.term_type = "idSoce"
								search.save
							rescue #ActiveResource::ServerError
								#@hruid = "on t'as pas trouvé :-("

								#Si on ne trouve rien, on cherche dans platal l'adresse mail
								redirect = Redirectplatal.where(redirect: a).take
								if !redirect.nil?
									@hruid = Userplatal.find(redirect.uid).hruid
									search.term_type = "Email Platal"
									search.save
								else
					    			# format.html { redirect_to recovery_support_path() }
					    			search.term_type = "Non trouvé"
									search.save
					    			format.html { redirect_to recovery_path(:retry => true) }
					    		end

					    		
					    	end
					    end

					end
				else
					format.html { redirect_to recovery_path, notice: "Nous n'acceptons pas les robots ici!"}

				end

				session = Recoverysession.new
				session.generate_token
				session.hruid = @hruid
				session.expire_date = DateTime.now + 15.minute # on definit la durée de vie d'un token à 15 minutes
				session.save

				format.html { redirect_to recovery_step1_path(:token_session => session.token) }
			else
				search.term_type = "Recherche vide"
				search.save
				format.html { redirect_to recovery_path, notice: "Tu dois rentrer un identifiant, email ou numéro de sociétaire pour que nous puissions t'identifier!"}
			end
		end

	end



	def recovery_step1
		@session_token = params[:token_session]
		session = Recoverysession.find_by(token: @session_token)

		if !session.nil? && session.usable?
			#on recupere l'utilisateur dans le site soce
			soce_user = Usersoce.where(hruid: session.hruid).take

			# cherche le numéro de téléhpone sur le site soce
			!soce_user.nil? ?  phone = soce_user.tel_mobile : phone = nil
			if !phone.nil?
				@phone_hidden = hide_phone(phone)
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
		@list_emails.push(soce_user.emails_valides) unless soce_user.nil?

		@list_emails = @list_emails.flatten.uniq
		
		# on supprime les adresses en gadz.org pour éviter d'avoir des doublons
		# je l'ai commenté parce que les emails du gram ne sont pas forcement à jour
		#@list_emails = @list_emails.drop_while{|e| /gadz.org/.match(e)}

		#@list_emails_to_display = @list_emails.map{|c|  /gadz/.match(c)? "Adresse @gadz.org": c[0]+c.gsub(/[A-Za-z0-9]/,"*")[1..c.length-3]+c[c.length-2..c.length-1]}
		@list_emails_to_display = @list_emails.map{|c|  /gadz/.match(c)? "Adresse @gadz.org": (c.split(".").first c.split(".").size-1).join(".").split("@").map{|a| a.split(".").map{|e| e[0]+e.gsub(/[A-Za-z0-9]/,"*")[1..e.length+1]}.join(".")}.join("@")+"."+c.split(".").last}


		#generation d'un token
		recovery_link = gen_uniq_link(@hruid)


		@r= recovery_link.get_url

		# on envoir les mails
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
			respond_to do |format|

				# on verifie que les mdp correspondent. Fait dans le modèle car semple impossible dans le model avec Active ressource
				if params[:user][:password] != params[:user][:password_confirmation] 
					format.html { redirect_to password_change_path(:token => token), notice: 'Les mots de passe ne correspondents pas' }
				else

					@hruid = recovery_link.hruid
					user_from_gram = GramAccount.find(@hruid)

					passwd_hash = Digest::SHA1.hexdigest params[:user][:password]
					user_from_gram.password = passwd_hash



					if user_from_gram.save
		        	  # si on a reussi à changer le mdp, on mraue le lien comme utilisé
		        	  recovery_link.set_used
		        	  format.html { redirect_to recovery_final_path, notice: 'mot de passe changé' }

		        	else
		        		format.html { redirect_to password_change_path(:token => token), notice: 'erreur lors de la maj du mot de passe', :layout => 'recovery'}

		        	end
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
		soce_user = Usersoce.where(hruid: hruid).take
		phone = soce_user.tel_mobile

		respond_to do |format|
			if session.sms_count.nil? || session.sms_count < 3

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
				#On parse le numéro de téléhpone pour qu'il soit du type 0033 612345678
				internat_phone = phone_parse(phone)
				send_sms(internat_phone.to_s,recovery_sms.token.to_s)

				# ou ajoute un au compteur
				session.sms_count.nil? ? session.sms_count = 1 : session.sms_count +=1
				session.save

				format.html { redirect_to recovery_sms_path(:token_session => session_token) }
			else
				format.html { redirect_to recovery_path, notice: 'Nombre maximun de sms atteint pour cette session' }

			end
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
			if !sms_uniq.nil? && sms_uniq.usable? && !session.nil? && session.usable? && session.hruid == sms_uniq.hruid
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
		@phone_hidden = hide_phone(phone)

		render :layout => 'recovery'
	end

	def recovery_final
		render :layout => 'recovery'
	end
	def recovery_support
		@user = User.new
		render :layout => 'recovery'
	end

	def recovery_support_final
		# TODO recuperer les params du port et les mettre dans les mailer
		name  = params[:nom]
		firstname = params[:prenom]
		email = params[:email]
		birthdate = params[:ddn][:day] + "/" + params[:ddn][:month] + "/" + params[:ddn][:year]
		phone = params[:telephone]
		desc = params[:issue]

				    		#format.html { redirect_to recovery_path(), alert: 'Nombre maximum de tentatives atteint ' }

		#Supportmailer.support_email(name,firstname,email,birthdate,phone,desc).deliver_now
		message = support_message(name,firstname,email,birthdate,phone,desc)
		create_jira_ticket(email,message,email)
		render :layout => 'recovery'
	end

	def dashboard
		authorize! :read, @user
		hruid = @user.hruid
		@user_from_gram = GramAccount.find(hruid)
		@user_from_soce = Usersoce.where(hruid: hruid).take
		@user_from_platal = Userplatal.where(hruid: hruid).take

	end


	private

		    # Use callbacks to share common setup or constraints between actions.
		    def set_user
		    	@user =(params[:user_id] ?  User.find(params[:user_id]) : current_user)
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

		def send_sms(phone_number,code)
			base_url = "https://www.ovh.com/cgi-bin/sms/http2sms.cgi?"
			account = Rails.application.secrets.ovh_sms_account
			login = Rails.application.secrets.ovh_sms_login
			password = Rails.application.secrets.ovh_sms_password
			from = Rails.application.secrets.ovh_sms_from
			message = "Ton code de validation Gadz.org est: " + code

			full_url = base_url + "account=" + account + "&login=" + login + "&password=" + password + "&from=" + from + "&to=" + phone_number + "&message=" + message + "&noStop=1"

  			# on envoie la requete get en https 
  			# TODO il serait bien de regarder le code de réponse
  			encoded_url = URI.encode(full_url)
  			uri = URI.parse(encoded_url)

  			http = Net::HTTP.new(uri.host, uri.port)
  			http.use_ssl = true if uri.scheme == 'https'

  			http.start do |h|
  				h.request Net::HTTP::Get.new(uri.request_uri)
  				logger.info "#--------------------------------------------------------------------URL"
  				logger.info(h)
  			end
  		end

  		def phone_parse(phone)
	    	if phone.length == 14 || phone.length == 10 #10 et les points ou sans
	    		internat_phone = "0033"+phone.gsub(".","").split(//).join[1..9] 
	    	elsif phone.length > 15 # pour les numeros de tel étranger 0033.123.456.789 avec la possibilité d'avoir un indicatif à 3 chiffres et des point tous les 2 chiffre
	    		internat_phone = phone.gsub(".","")
	    	end
	    	return internat_phone
	    end

	    def hide_phone(phone)
	    	internat_phone = phone_parse(phone)
	    	hiden_phone = "+" + internat_phone.gsub("."," ").split(//)[2..4].join + " xx xx xx " + internat_phone.gsub("."," ").split(//).last(2).join
	    end

	    def create_jira_ticket(user, description, sender)
	    	newjira = JiraIssue.new(
	    		fields: { 
	    			project: { id: "10001" }, 
	    			summary: "L'utilisateur #{user} signale ne pas arriver à se connecter", 
	    			description: description, 
	    			customfield_10000: sender , 
	    			issuetype: { id: "1" }, 
	    			labels: [ "mdp" ] 
	    			})
	    	newjira.save
	    end

	    def support_message(name,firstname,email,birthdate,phone,desc)
	    	message = (
	    		"Nom: " + name +
	    		"\nPrenom: " + firstname +
	    		"\nEmail: " + email +
	    		"\nDate de naissance: " + birthdate +
	    		"\nTéléphone: " + phone +
	    		"\n\n" + desc )
	    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
    	params.require(:user).permit(:email, :firstname, :lastname, :hruid, :id, :role_id)
    end

end
