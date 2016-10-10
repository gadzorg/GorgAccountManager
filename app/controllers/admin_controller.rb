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

  def search_user
    authorize! :read, :admin
    @user = User.new
    user = params[:user]
    
      if user.present?
        respond_to do |format|
        a = params[:user][:hruid].to_s.strip
        begin
          @uuid = GramV2Client::Account.find(a).uuid
        rescue
          begin
            @uuid = GramV2Client::Account.where(email: a).first.uuid
          rescue #ArgumentError ||  ActiveResource::ResourceNotFound
            begin
              @uuid = GramV2Client::Account.where(hruid: a).first.uuid
            rescue #ActiveResource::ResourceNotFound || ArgumentError
              begin
                id_soce = a.gsub(/[a-zA-Z]/,'')
                id_soce.to_i.to_s.to_i == id_soce ? (id_soce_to_search = id_soce) : (id_soce_to_search = nil)
                @uuid = GramV2Client::Account.where(id_soce: id_soce_to_search).first.uuid
              rescue #ActiveResource::ServerError
                #@hruid = "on t'as pas trouvé :-("

                    format.html { redirect_to admin_search_user_path , notice: "Désol's, j'ai rien trouvé"}

              end
            end
          end
        end
        format.html { redirect_to admin_info_user_path(:uuid => @uuid) }
      end
    end #end repond_to 
  end

  def info_user
  	authorize! :read, :admin
    @user = User.new
  	uuid = params[:uuid]
  	@user_from_gram = GramV2Client::Account.find(uuid)
    hruid = @user_from_gram.hruid
	  @user_from_soce = Soce::User.where(hruid: hruid).take
	  @user_from_platal = Userplatal.where(hruid: hruid).take

  end

  def recovery_sessions
  	authorize! :read, :admin
  	@sessions = Recoverysession.all
  end

  def inscriptions
    authorize! :read, :admin

    @inscription_links = Uniqlink.where(inscription: true)

    @newgorgaccounts = Newgorgaccount.all.map{|a| [a.hruid, true].join(";")}.join("\n")
    @newgorgaccounts_gapps = Newgorgaccount.all.where(wantsgoogleapps: true).map{|a| a.hruid}.join("\n")
  end

  def add_inscriptions
    authorize! :read, :admin
    hruids=params[:hruids].split("\r\n")
    hruids.each do |hruid|
      # pour chaque ligne on créé un nouveau lien de récup

      user_from_soce = Soce::User.where(hruid: hruid).take
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
