class UsersController < ApplicationController
	require 'net/http'
	before_action :set_user, only: [:show, :edit, :update, :destroy, :dashboard, :flag, :password_change_logged, :password_change_logged_step2 ]
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
        format.html { redirect_to @user, notice: I18n.translate('users.flash.create.success', user: @user.fullname) }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, notice: I18n.translate('users.flash.create.fail') , status: :unprocessable_entity }
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
        format.html { redirect_to @user, notice: I18n.translate('users.flash.update.success', user: @user.fullname) }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, notice: I18n.translate('users.flash.update.fail', user: @user.fullname) , status: :unprocessable_entity}
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy

    authorize! :destroy, @user
    username=@user.fullname
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice:  I18n.translate('users.flash.destroy.success', user: username) }
      format.json { head :no_content }
    end
  end


  def search_by_id
  	redirect_to user_path(params[:id])
  end

  def recovery
  	@user = User.new
		re_try = params[:retry] #true si on vient d'échoucher. la page est appellée en POST
		help = params[:help]
		if !re_try.nil? || re_try == true
			@first_attempt = false
		else
			@first_attempt = true
		end
		if help.nil? || help == false
			@help = false
		else
			@help = true
		end
		@hruid = params[:hruid]
	render :layout => 'recovery'
	end

	def create_recovery_session
		# on elimine les espaces en dùebut/fin du mot recherché 
		a = params[:user][:hruid].to_s.strip
		#on enregistre les recherches pour les stats
		search = Search.new(term: a)
		respond_to do |format|

			if !a.nil? && a != "" # on verifie si la recherche n'est pas vide
				if verify_recaptcha
				#on cherche si ce qui est rentré dans le formulaire est un email, hrui ou num soce via l'api GrAM
				begin
					@uuid = GramV2Client::Account.where(email: a).first.uuid
					search.term_type = "Email GrAM"
					search.save
				rescue #ArgumentError ||  ActiveResource::ResourceNotFound
					begin
						@uuid = GramV2Client::Account.where(hruid: a).first.uuid
						search.term_type = "Hruid"
						search.save
					rescue #ActiveResource::ResourceNotFound || ArgumentError
						begin
							id_soce = Integer(a.gsub(/[a-zA-Z]/,''))
							@uuid = GramV2Client::Account.where(id_soce: id_soce).first.uuid
							search.term_type = "idSoce"
							search.save
						rescue #ActiveResource::ServerError
							#@hruid = "on t'as pas trouvé :-("

							#Si on ne trouve rien, on cherche dans platal l'adresse mail
					    		# format.html { redirect_to recovery_support_path() }
					    		search.term_type = "Non trouvé"
							search.save
							format.html { redirect_to recovery_path(:retry => true) }
					    		
					    	end
					    end

					end
				else
					format.html { redirect_to recovery_path(help: true), notice: 'As-tu bien coché la case "je ne suis pas un robot?"'}

				end

				#on genere ici un token de session pour povoir tranmettre les info d'un page à une autre sans exposer l'hrui à l'utilisateur
				session = Recoverysession.new
				session.generate_token
				session.uuid = @uuid
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
		#ok bon on l'a trouvé, maintenant on liste ses adresses mail
		uuid = session.uuid
		user_from_gram = GramV2Client::Account.find(uuid)
		hruid = user_from_gram.hruid

		if !session.nil? && session.usable?
			#on recupere l'utilisateur dans le site soce
			soce_user = Soce::User.where(hruid: hruid).take

			# cherche le numéro de téléhpone sur le site soce
			!soce_user.nil? ?  phone = soce_user.tel_mobile : phone = nil
			if phone.present?
				@phone_hidden = hide_phone(phone)
				!@phone_hidden == false ? @have_phone = true : @have_phone = false
			else
				@have_phone = false
			end

		
		list_emails = get_emails(user_from_gram,soce_user)
		@list_emails_to_display = list_emails.map{|c|  /gadz/.match(c)? "Adresse @gadz.org": (c.split(".").first c.split(".").size-1).join(".").split("@").map{|a| a.split(".").map{|e| e[0]+e.gsub(/[A-Za-z0-9]/,"*")[1..e.length+1]}.join(".")}.join("@")+"."+c.split(".").last}




			render :layout => 'recovery'
		else
			respond_to do |format|
				format.html { redirect_to root_path, notice: 'Délais dépassé' }
			end
		end



	end


	def recovery_step2
		@session_token = params[:token_session]
		# on recupère l'hruid à partir du token de session
		session = Recoverysession.find_by(token: @session_token)
		@uuid = session.uuid

		#ok bon on l'a trouvé, maintenant on liste ses adresses mail
		user_from_gram = GramV2Client::Account.find(@uuid)
		@hruid = user_from_gram.hruid

		#on recupere l'utilisateur dans le site soce
		soce_user = Soce::User.where(hruid: @hruid).take

		!soce_user.nil? ?  phone = soce_user.tel_mobile : phone = nil
		if phone.present?
			@phone_hidden = hide_phone(phone)
			!@phone_hidden == false ? @have_phone = true : @have_phone = false
		else
			@have_phone = false
		end

		# TODO mettres des if not nil
		#emails du gram
		
		@list_emails = get_emails(user_from_gram,soce_user)

		@list_emails_to_display = @list_emails.delete_if{|e| e.include?("gadz.fr")}.map{|c|  /gadz.org/.match(c)? "Adresse @gadz.org": (c.split(".").first c.split(".").size-1).join(".").split("@").map{|a| a.split(".").map{|e| e[0]+e.gsub(/[A-Za-z0-9]/,"*")[1..e.length+1]}.join(".")}.join("@")+"."+c.split(".").last}


		#generation d'un token
		recovery_link = gen_uniq_link(@uuid)


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
				elsif not PasswordService.validate_password_rules params[:user][:password]
					flash[:error] = 'Le mot de passe est trop court ou contient des accents'
					format.html { redirect_to user_password_change_logged_path() }
				else

					uuid = recovery_link.uuid
					user_from_gram = GramV2Client::Account.find(uuid)
					@hruid = user_from_gram.hruid
					user_from_soce = Soce::User.where(hruid: @hruid).take

					passwd_hash = Digest::SHA1.hexdigest params[:user][:password]
					user_from_gram.password = passwd_hash
					user_from_soce.pass_crypt = passwd_hash unless user_from_soce.nil?

					user_from_gram_saved = user_from_gram.save
					user_from_soce_saved = user_from_soce.save unless user_from_soce.nil?
					if user_from_gram_saved && user_from_soce_saved
						# si on a reussi à changer le mdp, on mraue le lien comme utilisé
						recovery_link.set_used
						format.html { redirect_to recovery_final_path, notice: 'mot de passe changé' }
					elsif user_from_gram_saved && !user_from_soce_saved
						recovery_link.set_used
						format.html { redirect_to recovery_final_path, notice: 'mot de passe changé mais compte SOCE introuvable' }
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

	def password_change_logged
		authorize! :update_password, @user
		re_try = params[:retry] #true si on vient d'échoucher
		if !re_try.nil? || re_try == true
			@first_attempt = false
		else
			@first_attempt = true
		end
	end

	def password_change_logged_step2
		authorize! :update_password, @user
		respond_to do |format|
			# on verifie que les mdp correspondent. Fait dans le modèle car semple impossible dans le model avec Active ressource
			if params[:user][:password] != params[:user][:password_confirmation]
				flash[:error] = 'Les mots de passe ne correspondents pas'
				format.html { redirect_to user_password_change_logged_path() }
			elsif not PasswordService.validate_password_rules params[:user][:password]
				flash[:error] = 'Le mot de passe est trop court ou contient des accents'
				format.html { redirect_to user_password_change_logged_path() }
			else

				uuid = @user.uuid
				current_password_hash_from_gram = GramV2Client::Account.find(uuid, :params => {show_password_hash: true}).password
				puts current_password_hash_from_gram
				current_password_hash = Digest::SHA1.hexdigest params[:user][:password_current]
				if current_password_hash == current_password_hash_from_gram
					user_from_gram = GramV2Client::Account.find(uuid)
					@hruid = user_from_gram.hruid
					user_from_soce = Soce::User.where(hruid: @hruid).take

					passwd_hash = Digest::SHA1.hexdigest params[:user][:password]
					user_from_gram.password = passwd_hash
					user_from_soce.pass_crypt = passwd_hash

					if user_from_gram.save && user_from_soce.save
						format.html { redirect_to recovery_final_path, notice: 'mot de passe changé' }

					else
						flash[:error] = 'Erreur lors de la mise à jour du mot de passe'
						format.html { redirect_to user_password_change_path(:token => token), :layout => 'recovery'}

					end
				else
					flash[:error] = 'Le mot de passe actuel du compte ne correspond pas'
					format.html { redirect_to user_password_change_logged_path(retry: true)}
				end
			end
		end

	end

	def recovery_inscription
		@tbk = ["ch","an","kin","cl","li","pa","bo","ka","me" ]
		@user = User.new
		token = params[:token]
		recovery_link = Uniqlink.find_by(token: token)
		if recovery_link.usable?
			respond_to do |format|
				@hruid = recovery_link.hruid
				@user_soce = Soce::User.where(hruid: @hruid).take
				format.html {render :layout => 'recovery'}
			end
		end

	end

	def password_change_inscription
		tbk = ["ch","an","kin","cl","li","pa","bo","ka","me" ]

		token = params[:token]
		password = params[:user_password]
		password_confirmation = params[:user_password_confirmation]
		prenom = params[:prenom]
		nom = params[:nom]
		bucque = params[:bucque]
		fams = params[:fams]
		telephone = params[:telephone]
		promo = params[:promo]
		email = params[:email]
		cgu_gorg = params[:cgu_gorg] ? true : false
		gapps = !params[:gapps] ? true : false #true si gapps = nil false si gapps = false
		date_naissance = Date.parse(params[:ddn][:year]+params[:ddn][:month].to_s.rjust(2, "0")+params[:ddn][:day].to_s.rjust(2, "0")).strftime("%Y-%m-%d")


		recovery_link = Uniqlink.find_by(token: token)

		if recovery_link.usable?
			respond_to do |format|
				if telephone.count(".") > 3 && prenom != "" && nom != "" && email != "" && validate_alpha_accent(prenom) && validate_alpha_accent(nom) && validate_alpha_accent(bucque) && validate_fams(fams) && email.exclude?("gadz.org") && email.include?("@") && email.include?(".")


					# on verifie que les mdp correspondent. Fait dans le modèle car semple impossible dans le model avec Active ressource
					if password != password_confirmation || password == ""
						format.html { redirect_to user_recovery_inscription_path(:token => token), notice: 'Les mots de passe ne correspondents pas ou sont vides' }
					else

						uuid = recovery_link.uuid
						user_from_gram = GramV2Client::Account.find(uuid)
						@hruid = user_from_gram.hruid
						soce_user = Soce::User.where(hruid: @hruid).take

						passwd_hash = Digest::SHA1.hexdigest password_confirmation

						#mise à jour du compte SOCE
						soce_user.nom = nom
						soce_user.prenom = prenom
						soce_user.famille1 = fams
						soce_user.surnom = bucque
						#soce_user.promo1 = promo #on ne permet pas de modifier la promo pour l'instant
						soce_user.email = email
						soce_user.tel_mobile = telephone
						soce_user.date_naissance = date_naissance
						soce_user.pass_crypt = passwd_hash

						#mise à jour du compte GrAM
						user_from_gram.lastname = nom
						user_from_gram.firstname = prenom
						user_from_gram.birthdate = date_naissance +" 00:00:00"
						user_from_gram.password = passwd_hash

						#creation de l'entrée pour le compte platal à créer
						newgorgaccount = Newgorgaccount.new
						newgorgaccount.email = email
						newgorgaccount.hruid = @hruid
						newgorgaccount.promo = soce_user.promo1
						newgorgaccount.tbk = tbk[soce_user.centre1.to_i - 1 ]
						# activer CGU à l'inscription
						if cgu_gorg
							#valider les cgu dans GrAM
							user_from_gram.loginvalidationcheck = "CGU="+DateTime.now.strftime("%Y-%m-%d")
						end
						# action si google apps coché
						if gapps
							newgorgaccount.wantsgoogleapps = true
						else
							newgorgaccount.wantsgoogleapps = false
						end
						
						if user_from_gram.save && soce_user.save && newgorgaccount.save
			        	  # si on a reussi à changer le mdp, on marque le lien comme utilisé
			        	  recovery_link.set_used
			        	  format.html { redirect_to recovery_inscription_final_path, notice: 'Ton compte se fait usiner!' }

			        	else
			        		format.html { redirect_to user_recovery_inscription_path(:token => token), notice: 'erreur lors de la mise à jour de ton compte', :layout => 'recovery'}

			        	end
			        end
			    else
			    	format.html { redirect_to user_recovery_inscription_path(:token => token), notice: 'Tu as laissé des champs vides ou mal renseignés :-(', :layout => 'recovery'} 
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
		# on recupère l'uuid à partir du token de session
		session = Recoverysession.find_by(token: session_token)
		uuid = session.uuid
		user_from_gram = GramV2Client::Account.find(uuid)
		hruid = user_from_gram.hruid

		soce_user = Soce::User.where(hruid: hruid).take
		phone = soce_user.tel_mobile

		respond_to do |format|
			if session.sms_count.nil? || session.sms_count < 3

				#on genere un code pour le sms
				recovery_sms = Uniqsms.new
				recovery_sms.generate_token
				recovery_sms.hruid = hruid
				recovery_sms.uuid = uuid
				recovery_sms.used = false
				recovery_sms.expire_date = DateTime.now + 10.minute # on definit la durée de vie d'un token à 10 minutes
				recovery_sms.save

				#generation d'un token parce qu'on va en avoir besoin 
				# quand on sera redirigé sur la pase de changement de mdp
				recovery_link = gen_uniq_link(uuid)

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
			if !sms_uniq.nil? && sms_uniq.usable? && !session.nil? && session.usable? && session.uuid == sms_uniq.uuid
				if sms_uniq.check_count < 4 #nombre max de verifications add_check ajoute et renvoie le nombre de verif
					uuid = sms_uniq.uuid
					token = Uniqlink.where(uuid: uuid).where(used: false).last.token
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
		@session_token = params[:token_session]
		# on recupère l'hruid à partir du token de session
		session = Recoverysession.find_by(token: @session_token)
		uuid = session.uuid
		user_from_gram = GramV2Client::Account.find(uuid)
		hruid = user_from_gram.hruid

		#on recupere l'utilisateur dans le site soce
		soce_user = Soce::User.where(hruid: hruid).take
		phone = soce_user.tel_mobile
		@phone_hidden = hide_phone(phone)

		render :layout => 'recovery'
	end

	def recovery_final
		render :layout => 'recovery'
	end

	def recovery_inscription_final
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
		uuid = @user.uuid
		@user_from_gram = GramV2Client::Account.find(uuid)
		@hruid = user_from_gram.hruid
		@user_from_soce = Soce::User.where(hruid: hruid).take
		@user_from_platal = Userplatal.where(hruid: hruid).take

	end

	def sync_with_gram
		authorize! :sync, @user
		respond_to do |format|
		  if @user.syncable? && ( @user.next_sync_allowed_at <= Time.now)
		    if @user.update_from_gram
		      format.html { redirect_to @user, notice: I18n.translate('users.flash.sync.success', user: @user.fullname) }
		      format.json { render :show, status: :ok, location: @user }
		    else
		      format.html { redirect_to @user, notice: I18n.translate('users.flash.sync.fail', user: @user.fullname)}
		      format.json { render json: '{"error": "Problems occured during syncronization"}', status: :unprocessable_entity }
		    end
		  else
		    format.html { redirect_to @user, notice: I18n.translate('users.flash.sync.too_soon', user: @user.fullname, eta: (@user.next_sync_allowed_at-Time.now).round)}
		    format.json { render json: "{\"error\": \"Try again in #{(@user.next_sync_allowed_at-Time.now).round} seconds\"}", status: :unprocessable_entity }
		  end
		end
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

	    def gen_uniq_link(uuid)
			recovery_link = Uniqlink.new
			recovery_link.generate_token
			recovery_link.uuid = uuid
			recovery_link.used = false
			recovery_link.inscription = false
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
	    	if phone[0] == "+"
	    		internat_phone = phone.gsub("+","00")
	    	elsif phone.length == 14 || phone.length == 10 #10 et les points ou sans
	    		internat_phone = "0033"+phone.gsub(".","").split(//).join[1..9] 
	    	elsif phone.length > 15 # pour les numeros de tel étranger 0033.123.456.789 avec la possibilité d'avoir un indicatif à 3 chiffres et des point tous les 2 chiffre
	    		internat_phone = phone.gsub(".","")
	    	else
	    		return false 
	    	end
	    	return internat_phone
	    end

	    def hide_phone(phone)
	    	internat_phone = phone_parse(phone)
	    	return false if internat_phone == false #on quite la fonction si le numéro de télephone n'est pas reconnu ou parsable
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

	    def get_emails(user_from_gram,soce_user)
			list_emails = Array.new
			list_emails.push(user_from_gram.mail_forwarding) if user_from_gram.respond_to?(:mail_forwarding)

			#@list_emails.push(user_from_gram.mail_alias)
			list_emails.push(user_from_gram.email) if user_from_gram.email.present? && user_from_gram.respond_to?(:email)
			#list_emails.push(user_from_gram.email_forge) if user_from_gram.email_forge.present? && user_from_gram.respond_to?(:email_forge)
			#email du site soce
			list_emails.push(soce_user.emails_valides) unless soce_user.blank?

			list_emails = list_emails.flatten.uniq
			list_emails = list_emails.reject(&:blank?) #on supprime les emails vides

			# on supprime les adresses en gadz.org pour éviter d'avoir des doublons
			# je l'ai commenté parce que les emails du gram ne sont pas forcement à jour
			# @list_emails = @list_emails.drop_while{|e| /gadz.org/.match(e)}

			#@list_emails_to_display = @list_emails.map{|c|  /gadz/.match(c)? "Adresse @gadz.org": c[0]+c.gsub(/[A-Za-z0-9]/,"*")[1..c.length-3]+c[c.length-2..c.length-1]}
	    end

	    # retourne true si valide
	    def validate_alpha_accent str
			(ActiveSupport::Inflector.transliterate(str) =~ /^[a-zA-Z\'\-\s]*$/ ) == nil ? false : true
		end

		# autorise uniquement les chiffre,-,! et µ
		def validate_fams str
			(ActiveSupport::Inflector.transliterate(str.gsub("µ","")) =~ /^[0-9\!\-\s]*$/ ) == nil ? false : true		
		end


    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :firstname, :lastname, :hruid, :id, :role_id, :password, :password_confirmation)

    end

end
