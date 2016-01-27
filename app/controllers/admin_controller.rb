class AdminController < ApplicationController
  
  def index
    authorize! :read, :admin
  end

  def stats
    authorize! :read, :admin
    @links_count = Uniqlink.all.count
    @sessions_count = Recoverysession.all.count
    @sms_count = Uniqsms.all.count

    @top_hruid = Recoverysession.all.map{|r| r.hruid}.each_with_object(Hash.new(0)) { |hruid,counts| counts[hruid] += 1 }.sort_by{|hruid,count| count}.reverse.take(10)
    @search_term_type = Search.all.map{|s| s.term_type}.each_with_object(Hash.new(0)) { |tt,counts| counts[tt] += 1 }.sort_by{|tt,count| count}.reverse
  end

  def searches
  	authorize! :read, :admin
  	@searches = Search.all
  end

  def info_user
  	authorize! :read, :admin
  	hruid = params[:hruid]
  	@user_from_gram = GramAccount.find(hruid)
	@user_from_soce = Usersoce.where(hruid: hruid).take
	@user_from_platal = Userplatal.where(hruid: hruid).take

  end

  def recovery_sessions
  	authorize! :read, :admin
  	@sessions = Recoverysession.all
  end

  def inscriptions
    authorize! :read, :admin

    @inscription_links = Uniqlink.where(inscription: true)
  end

  def add_inscriptions
    authorize! :read, :admin
    hruids=params[:hruids].split("\r\n")
    hruids.each do |hruid|
      # pour chaque ligne on créé un nouveau lien de récup

      user_from_soce = Usersoce.where(hruid: hruid).take
      email = user_from_soce.email
      recovery_link = Uniqlink.new(
        hruid: hruid,
        inscription: true,
        email: email
      )
      recovery_link.generate_token
      recovery_link.save
      InscriptionMailer.inscription_email(email, recovery_link.get_inscription_url, user_from_soce.nom, user_from_soce.prenom ).deliver_now
    end
    respond_to do |format|
      format.html{ redirect_to admin_inscriptions_path}
    end

  end
end
