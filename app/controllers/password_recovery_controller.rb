class PasswordRecoveryController < ApplicationController

  def recovery
    @user = User.new
    @first_attempt = !params[:retry] #true si on vient d'échouer. la page est appellée en POST
    @help = !!params[:help] #Force boolean conversion
    @query = params[:recovery_query]
    render :layout => 'recovery'
  end

  def create_recovery_session
    # on elimine les espaces en debut/fin du mot recherché
    query = params[:user][:recovery_query].to_s.strip.downcase
    #on enregistre les recherches pour les stats
    search = Search.new(term: query)

    unless verify_recaptcha
      return redirect_to(recovery_path(help: true, recovery_query: query), notice: 'As-tu bien coché la case "je ne suis pas un robot?"')
    end

    search_logger=SearchLogger.new
    begin
      @uuid=GramAccountSearcher.new(query, search_logger: search_logger).uuid
    rescue GramAccountSearcher::BlankQuery
      return redirect_to(recovery_path, notice: "Tu dois rentrer un identifiant, email ou numéro de sociétaire pour que nous puissions t'identifier!")
    end

    unless @uuid
      return redirect_to(recovery_path(:retry => true, recovery_query: query))
    end

    #on genere ici un token de session pour povoir tranmettre les info d'un page à une autre sans exposer l'hruid à l'utilisateur
    session = Recoverysession.initialize_for(@uuid)

    redirect_to recovery_step1_path(:token_session => session.token)
  end



  def recovery_step1
    @session_token = params[:token_session]
    session = Recoverysession.find_by(token: @session_token)

    if !session.nil? && session.usable?
      #ok bon on l'a trouvé, maintenant on liste ses adresses mail
      uuid = session.uuid
      user_from_gram = GramV2Client::Account.find(uuid)
      hruid = user_from_gram.hruid


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


      list_emails = RecoveryService.get_emails(user_from_gram,soce_user)
      @list_emails_to_display = list_emails.map{|c|  /gadz/.match(c)? "Adresse @gadz.org": (c.split(".").first c.split(".").size-1).join(".").split("@").map{|a| a.split(".").map{|e| e[0]+e.gsub(/[A-Za-z0-9]/,"*")[1..e.length+1]}.join(".")}.join("@")+"."+c.split(".").last}




      render :layout => 'recovery'
    else
      respond_to do |format|
        format.html { redirect_to recovery_path, notice: 'Session expirée' }
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

    @list_emails = RecoveryService.get_emails(user_from_gram,soce_user)

    @list_emails_to_display = @list_emails.delete_if{|e| e.include?("gadz.fr")}.map{|c|  /gadz.org/.match(c)? "Adresse @gadz.org": (c.split(".").first c.split(".").size-1).join(".").split("@").map{|a| a.split(".").map{|e| e[0]+e.gsub(/[A-Za-z0-9]/,"*")[1..e.length+1]}.join(".")}.join("@")+"."+c.split(".").last}


    #generation d'un token
    recovery_link = Uniqlink.generate_for_uuid(@uuid)


    @r= recovery_link.get_url

    # on envoir les mails
    @list_emails.each do |email|
      Recoverymailer.recovery_email(email, recovery_link.get_url, @hruid ).deliver_now
    end

    render :layout => 'recovery'

  end

  def password_reset
    @token = params[:token]
    recovery_link = Uniqlink.find_by(token: @token)
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
          ps=PasswordService.new(params[:user][:password])
          if ps.validate
            uuid = recovery_link.uuid

            user_from_gram_saved, user_from_soce_saved = ps.update_soce_and_gram_password(uuid)
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
          else
            flash[:error] = "Le mot de passe n'est pas valide car il : #{ps.errors.join(", ")}"
            format.html { redirect_to password_change_path(token) }
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
        recovery_link = Uniqlink.generate_for_uuid(uuid)

        #ici code envoi sms
        #On parse le numéro de téléhpone pour qu'il soit du type 0033 612345678
        internat_phone = SmsService.phone_parse(phone)
        SmsService.send_sms(internat_phone.to_s,recovery_sms.token.to_s)

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
    message = JiraService.support_message(name,firstname,email,birthdate,phone,desc)
    JiraService.create_recovery_ticket(email,message,email)
    render :layout => 'recovery'
  end

  private


  def hide_phone(phone)
    internat_phone = SmsService.phone_parse(phone)
    return false if internat_phone == false #on quite la fonction si le numéro de télephone n'est pas reconnu ou parsable
    hiden_phone = "+" + internat_phone.gsub("."," ").split(//)[2..4].join + " xx xx xx " + internat_phone.gsub("."," ").split(//).last(2).join
  end

end
