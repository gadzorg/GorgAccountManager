class PasswordRecoveryController < ApplicationController

  layout 'recovery'
  before_action :set_session, only: [:recovery_step1, :recovery_step2, :create_sms, :recovery_sms, :validate_sms]


  #GET /recovery
  #POST /recovery
  #Asks user for a way to be identified
  def recovery
    @user = User.new
    @first_attempt = !params[:retry] #true si on vient d'échouer. la page est appellée en POST
    @help = !!params[:help] #Force boolean conversion
    @query = params[:recovery_query] #Used to pre-filled field with previous value
  end

  #POST /create_recovery_session
  # Try to identify the User
  # Initialize a recovery session if successful
  # Redirect to Step 1  to choose a way to recover password
  def create_recovery_session
    # on elimine les espaces en debut/fin du mot recherché
    query = params[:user][:recovery_query].to_s.strip.downcase

    unless verify_recaptcha
      return redirect_to(recovery_path(help: true, recovery_query: query), notice: 'As-tu bien coché la case "je ne suis pas un robot?"')
    end

    #Create a search logger so this we can make some stats
    search_logger=SearchLogger.new
    begin
      #Perform a search and return UUID, nil if not found
      @uuid=GramAccountSearcher.new(query, search_logger: search_logger).uuid
    rescue GramAccountSearcher::BlankQuery
      #Raised if query is nil or ""
      return redirect_to(recovery_path, notice: "Tu dois rentrer un identifiant, email ou numéro de sociétaire pour que nous puissions t'identifier!")
    end

    unless @uuid
      #User not found, redirect to try again
      return redirect_to(recovery_path(:retry => true, recovery_query: query))
    end

    #on genere ici un token de session pour povoir tranmettre les info d'un page à une autre sans exposer l'hruid à l'utilisateur
    session = Recoverysession.initialize_for(@uuid)

    redirect_to recovery_step1_path(:token_session => session.token)
  end

  #GET /recovery_step1/:token_session
  # Check if session exists
  # If so, ask user which method to use to recover the password (email or SMS)
  def recovery_step1
    @phone_hidden=@recovery_service.hidden_phone_number
    @list_emails_to_display = @recovery_service.hidden_emails
  end


  #POST /recovery_step2
  # Check if session exists
  # If so send an email on each adresses of user
  # User mays switch to SMS recovery
  def recovery_step2
    @phone_hidden=@recovery_service.hidden_phone_number
    @list_emails_to_display = @recovery_service.hidden_emails

    #generation d'un token
    recovery_link = Uniqlink.generate_for_uuid(@session.uuid)

    # on envoie les mails
    @recovery_service.emails.each do |email|
      Recoverymailer.recovery_email(email, recovery_link.get_url, @recovery_service.gram_account.hruid ).deliver_now
    end
  end

  #POST /create_sms
  # Check if session exists
  # If User can send an SMS (max: 3), send a SMS with 6 digits token
  # Redirect to /recovery_sms to send the 6 digits token
  def create_sms
    phone = @recovery_service.phone_number

    unless @session.sms_count.to_i < 2 #3 sms max
      return redirect_to recovery_sms_path(:token_session => @session.token), notice: 'Nombre maximun de sms atteint pour cette session'
    end

    #on genere un code pour le sms
    recovery_sms = Uniqsms.generate_for_uuid(@session.uuid)

    #ici code envoi sms
    if SmsService.new(phone).send_recovery_message(recovery_sms.token.to_s)
      # ou ajoute un au compteur
      @session.add_sms_count
      redirect_to recovery_sms_path(:token_session => @session.token)
    else
      redirect_to recovery_sms_path(:token_session => @session.token, sending_error: true)
    end

  end

  #POST /validate_sms
  # Check if session exists
  # Check if SMS token match Session UUID
  # If so, create a passwordchange link and redirect user to it
  # Max 5 attempts per session, session expires on 6th
  def validate_sms
    #on récupere le mini token du sms et si il est bon,
    #on prend le token du mail pour aller à la page de changement de mdp
    token_sms = params[:token]
    sms_uniq = Uniqsms.find_by(token: token_sms)

    begin
      if @session.check_sms_token(sms_uniq)
        sms_uniq.set_used
        ul=Uniqlink.generate_for_uuid(@session.uuid)
        redirect_to password_change_path(:token => ul.token)
      else
        redirect_to recovery_sms_path(:token_session => @session.token), alert: 'Code invalide'
      end
    rescue Recoverysession::TooManySmsAttempts
      redirect_to recovery_path, alert: 'Nombre maximum de tentatives atteint '
    end
  end

  #GET /recovery_sms
  # Check if session exists
  # Ask user for a 6 digits token
  def recovery_sms
    @phone_hidden = @recovery_service.hidden_phone_number
    @sending_error=params[:sending_error]
    #TODO : Afficher un message d'erreur à l'utilisateur
  end

  #GET password_reset/:token
  # Check if password change link exists
  # Asks User for a new password
  def password_reset
    check_link_token

    @hruid = @recovery_link.hruid
    @user = User.new
  end

  #POST password_reset/:token
  # Check if password change link exists
  # Check if password validates rules
  # Send hashed password to GrAM and Soce (if exists)
  # Redirect to confirmation page
  def password_change
    check_link_token

    # on verifie que les mdp correspondent. Fait dans le modèle car semple impossible dans le model avec Active ressource
    if params[:user][:password] != params[:user][:password_confirmation]
      redirect_to password_change_path(:token => @token), alert: 'Les mots de passe ne correspondents pas'
    else
      ps=PasswordService.new(params[:user][:password])
      if ps.validate
        uuid = @recovery_link.uuid
        user_from_gram_saved, user_from_soce_saved = ps.update_soce_and_gram_password(uuid)
        if user_from_gram_saved
          # si on a reussi à changer le mdp, on mraue le lien comme utilisé
          @recovery_link.set_used
          message=user_from_soce_saved ? 'mot de passe changé' : 'mot de passe changé mais compte SOCE introuvable'
          redirect_to recovery_final_path, notice: message
        else
          redirect_to password_change_path(:token => @token), alert: 'erreur lors de la maj du mot de passe'
        end
      else
        flash[:error] = "Le mot de passe n'est pas valide car il : #{ps.errors.join(", ")}"
        redirect_to password_change_path(@token)
      end
    end
  end

  #GET recovery_final
  # Confirms that password have been changed
  def recovery_final
  end

  def recovery_support
    @user = User.new
  end

  def recovery_support_final
    # TODO recuperer les params du port et les mettre dans les mailer
    name  = params[:nom]
    firstname = params[:prenom]
    email = params[:email]
    birthdate = params[:ddn]
    phone = params[:telephone]
    desc = params[:issue]

    #format.html { redirect_to recovery_path(), alert: 'Nombre maximum de tentatives atteint ' }

    #Supportmailer.support_email(name,firstname,email,birthdate,phone,desc).deliver_now
    message = JiraService.support_message(name,firstname,email,birthdate,phone,desc)
    JiraService.create_recovery_ticket(email,message,email)
  end

  private

  #Set session from :token_session pram
  #Redirect to GET /recovery if session expired
  def set_session
    session_token = params[:token_session]
    @session = Recoverysession.find_by(token: session_token)

    #Redirect to recovery entry_point if invalid session
    redirect_to(recovery_path, notice: 'Session expirée') unless @session && @session.usable?
    @recovery_service=RecoveryService.new(@session)
  end

  #Check if recovery_link :token is valid
  #Redirecy to GET /recovery otherwise
  def check_link_token
      @token = params[:token]
      @recovery_link = Uniqlink.find_by(token: @token)
      unless @recovery_link && @recovery_link.usable?
        redirect_to recovery_path, notice: 'Ce lien a déjà été utilisé ou a expiré'
      end
    end

end
