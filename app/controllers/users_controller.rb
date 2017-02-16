class UsersController < ApplicationController
	require 'net/http'
	before_action :set_user, only: [:show, :edit, :update, :destroy, :dashboard, :flag, :password_change_logged, :password_change_logged_step2 ]
  autocomplete :user, :hruid , :full => true, :display_value =>:hruid#, extra_data: [:id, :firstname ] #, :scopes => [:search_by_name]

# GET /users
  # GET /users.json
  def index
    @query= params[:query]
  	@users = User.accessible_by(current_ability).search(@query).paginate(:page => params[:page])
    authorize! :update, @users
    if @users.count==1
      return redirect_to(user_path(@users.first.id))
    end
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
				format.html { redirect_to user_password_change_logged_path(@user) }
      else
        ps=PasswordService.new(params[:user][:password])
			  if ps.validate
          uuid = @user.uuid
          current_password_hash_from_gram = GramV2Client::Account.find(uuid, :params => {show_password_hash: true}).password
          puts current_password_hash_from_gram
          current_password_hash = Digest::SHA1.hexdigest params[:user][:password_current]
          if current_password_hash == current_password_hash_from_gram

            user_from_gram_saved, user_from_soce_saved = ps.update_soce_and_gram_password(uuid)

            if user_from_gram_saved && user_from_soce_saved
              format.html { redirect_to recovery_final_path, notice: 'mot de passe changé' }

            else
              flash[:error] = 'Erreur lors de la mise à jour du mot de passe'
              format.html { redirect_to user_password_change_path(:token => token), :layout => 'recovery'}

            end
          else
            flash[:error] = 'Le mot de passe actuel du compte ne correspond pas'
            format.html { redirect_to user_password_change_logged_path(retry: true)}
          end
        else
          flash[:error] = "Le mot de passe n'est pas valide car il : #{ps.errors.join(", ")}"
          format.html { redirect_to user_password_change_logged_path(@user) }
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

	def recovery_inscription_final
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
					id=params[:user_id]||params[:id]
		    	@user =(id ?  User.find_by_id_or_hruid_or_uuid(id) : current_user)
		    end
	    # Never trust parameters from the scary internet, only allow the white list through.
	    def user_params_pub
	    	params[:user].permit(:hruid)
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
