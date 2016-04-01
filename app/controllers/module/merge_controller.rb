class Module::MergeController < ApplicationController

  require 'fuzzystringmatch'
  require 'linkedin_scraper'

  def user
    # select current user if no params
    if params[:hruid]
      hruid = params[:hruid]
      @user = User.find_by(hruid: hruid) ||User.new # If user never logged in before, his acccount doesn't exist
    else
      @user=current_user
      hruid = @user && @user.hruid
    end
    authorize! :merge, @user
    @hruid = hruid

    @user_soce = Soce::User.where(hruid: hruid).take
    # info [titre, nom_du_champ, valeur_platal, valeur_soce, status {:same = déjà la meme valeur, :updatable=choix possible, :fixed=non modifiable}]
    info_platal=get_info_from_platal(hruid).first

    @infos = [
      {title: "Identifiant",field_name: "hruid",
        platal: info_platal['hruid'],
        soce:   @user_soce.hruid,
        status: :fixed},
      {title: "Prénom",field_name: "prenom",
        platal: formate_name(info_platal['firstname']),
        soce:   @user_soce.prenom,
        status: :updatable},
      {title: "Nom",field_name: "nom",
        platal: formate_name(info_platal['lastname']),
        soce:   @user_soce.nom,
        status: :updatable},
      {title: "Buque",field_name: "buktxt",
        platal: info_platal['buktxt'],
        soce:   @user_soce.surnom,
        status: :updatable},
      {title: "Buque Zaloeil",field_name: "bukzal",
        platal: info_platal['bukzal'],
        soce:   "champ à ajouter dans bdd SOCE", # TODO
        status: :updatable},
      {title: "Tabagn's",field_name: "centre1",
        platal: info_platal['tbk'],
        soce:   @user_soce.centre1.to_s.gsub(/[0-9]/, "1" => "ch", "2" => "an", "3" => "ai", "4" => "cl", "5" => "li", "6" => "pa", "7" => "bo", "8" => "ka", "9" => "me", "10" => "am"), #TODO Devrait être sortie dans un modèle
        status: :updatable},
      {title: "Email",field_name: "email",
        platal: info_platal['email'],
        soce:   @user_soce.email,
        status: :updatable},
      {title: "Télephone portable",field_name: "tel_mobile",
        platal: info_platal['search_tel'],
        soce:  @user_soce.tel_mobile,
        status: :updatable},
      {title: "Fam's",field_name: "famille1",
        platal: info_platal['gadz_fams'],
        soce:   @user_soce.famille1,
        status: :updatable},
      {title: "Fam's Zaloeil",field_name: "famille1zal",
        platal: info_platal['gadz_fams_display'],
        soce:   "champ à ajouter dans bdd SOCE",
        status: :updatable},
      {title: "Date de naissance",field_name: "date_naissance",
        platal: info_platal['birthdate'].nil? ? nil : info_platal['birthdate'].strftime("%d %b %Y") ,
        soce:   @user_soce.date_naissance.nil? ? nil : @user_soce.date_naissance.strftime("%d %b %Y") ,
        status: :updatable},
      {title: "date_declaration_deces",field_name: "date_declaration_deces",
        platal: info_platal['deathdate'],
        soce:   @user_soce.date_declaration_deces,
        status: :updatable},
    ]

    #Calcul des données identiques
    @infos.each{|i| i[:status] = :same if i[:platal] == i[:soce]}

    #On remplace les valeurs nil bar des ""
    @infos.each do |i|
      i[:platal] ||= ""
      i[:soce]   ||= ""
    end

    #On affiche pas  si les infos sont vides
    @infos.reject!{|i| i[:status] == :same && i[:platal].blank? }

    #On affiche pas les infos fixes
    @infos.reject!{|i| i[:status] == :fixed }    


    @phones_platal = get_phones_from_platal(hruid)


  end

  def address
    # select current user if no params
    # if params[:hruid].present?
    #   hruid = params[:hruid]
    # else
    #   @user=current_user
    #   hruid = @user.hruid if @user.present?
    # end
    hruid = params[:hruid]
    @user = User.where(hruid: hruid).take
    authorize! :merge, @user

    @phones_platal = get_phones_from_platal(hruid)

    @addresses_soce=Soce::User.find_by(hruid: hruid).address.serialize

    addresses_soce_formated = @addresses_soce.map do |a| 
      b=Geocoder.search(a.map(&:last)[0...-1].join(" ")).first
      b.formatted_address if b.present?
    end

    addresses_platal=get_addresses_from_platal(hruid)
    
    jarow = FuzzyStringMatch::JaroWinkler.create( :native )
    # retourne un tableau [ [tableau adresse soce], true si correspondace avec une adresse soce false sinon ]
    @addresses_platal=addresses_platal.map do |a|
      adresse_to_formate =  a["formatted_address"].present? ? a["formatted_address"] : a["postalText"]
      [
      formate_address_soce(Geocoder.search(adresse_to_formate).first), 
      addresses_soce_formated.map{ |b| jarow.getDistance(adresse_to_formate, b)}.max > 0.75,
      a["type"],
      case a["flags"]
      when /current/
        "(Principale)" 
      when /secondary/
        "(Secondaire)"
      end
      
      ]
    end

    @phones_adresse_platal = @phones_platal.select{|n| (n["link_type"].include? "address")}

    @socials_platal = get_socials_from_platal(hruid)
    @socials_soce = Soce::User.find_by(hruid: hruid).reseaux_sociaux


    @jobs_platal = get_jobs_from_platal(hruid).sort_by{ |k| k["entry_year"]}.reverse
    @jobs_soce = Soce::User.find_by(hruid: hruid).job.serialize unless Soce::User.find_by(hruid: hruid).job.empty?

    @diploma_platal = get_diploma_from_platal(hruid)
    @diploma_soce = Soce::User.find_by(hruid: hruid).diploma.serialize unless Soce::User.find_by(hruid: hruid).diploma.empty?

    @medal_platal = get_medal_from_platal(hruid)
    @medal_soce = Soce::User.find_by(hruid: hruid).medal.serialize unless Soce::User.find_by(hruid: hruid).medal.empty?

    #linkedintest
    linkedin_hash = @socials_platal.select{|n| (n["name"].include? "LinkedIn") if n["name"].present?}.first if @socials_platal.present?
    if linkedin_hash.present?
      linkedin_url = linkedin_hash["link"].gsub("%s",linkedin_hash["address"])
      #@linkedin_profile = Linkedin::Profile.get_profile(linkedin_url)
      @linkedin_past_companies = Linkedin::Profile.get_profile(linkedin_url).past_companies
    end


    render :layout => false
  end

  def update_soce_user
  end

  def user_merged
  end

  private
    def get_info_from_platal(hruid)
      sql = "select *, hruid, firstname, lastname, pgn.name as buktxt, pgn2.name as bukzal, email, gadz_fams, gadz_fams_display, birthdate, deathdate, search_tel, IF (tbk = 'kin', 'ai', tbk) as tbk
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profiles AS p ON (p.pid=ap.pid) 
        left JOIN profile_gadz_names AS pgn ON (pgn.pid = p.pid and pgn.type = 'buktxt')
        left JOIN profile_gadz_names AS pgn2 ON (pgn2.pid = p.pid and pgn2.type = 'bukzal')
        left join group_members on a.uid = group_members.uid
        left join groups on group_members.asso_id = groups.id
        left join profile_phones on (p.pid = profile_phones.pid and profile_phones.tel_type = 'mobile' and profile_phones.link_type = 'user')
        left join profile_campus_enum on p.campus = profile_campus_enum.id
        where groups.cat = 'Promotions'
        and hruid = '#{hruid}'"
      custom_sql_query(sql,PlatalDatabaseConnection)
    end

    def get_addresses_from_platal(hruid)
      sql = "select formatted_address, postalText, pa.type, pa.flags
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_addresses AS pa ON (pa.pid=ap.pid)
        where hruid = '#{hruid}'"
      custom_sql_query(sql,PlatalDatabaseConnection)
    end

    def get_jobs_from_platal(hruid)
      sql = "select pj.description AS job_desc, pj.email, pj.url AS job_url, entry_year, pje.name AS cpny_name, pje.url, NAF_code, pje.description AS cpny_desc, jte.name, jte.full_name
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_job AS pj ON (pj.pid=ap.pid)
        left JOIN profile_job_enum AS pje ON (pje.id=pj.jobid)
        left JOIN profile_job_term AS jt  ON (jt.pid = pj.pid AND jt.jid = pj.id)
        LEFT JOIN  profile_job_term_enum AS jte USING(jtid)
        where hruid = '#{hruid}'"
      custom_sql_query(sql,PlatalDatabaseConnection)
    end

    def get_socials_from_platal(hruid)
      sql = "select pn.*, pne.*
        FROM accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_networking AS pn ON ap.pid = pn.pid
        left JOIN profile_networking_enum AS pne ON pn.nwid = pne.nwid
        where hruid = '#{hruid}'"
      custom_sql_query(sql,PlatalDatabaseConnection)
    end

    def get_diploma_from_platal(hruid)
      sql = "Select *
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_education AS pe ON (ap.pid=pe.pid ) 
        left JOIN profile_education_enum AS pee ON (pee.id=pe.eduid )
        where not pee.id = 28  
        and hruid = '#{hruid}'"
      custom_sql_query(sql,PlatalDatabaseConnection)


    end

    def get_medal_from_platal(hruid)
      sql = "Select pme.type, pme.text AS medal_text, pmge.text AS medal_grade_text
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_medals AS pm ON (ap.pid=pm.pid ) 
        left JOIN profile_medal_enum AS pme ON (pme.id=pm.mid ) 
        left JOIN profile_medal_grade_enum AS pmge ON (pmge.mid=pm.mid and pmge.gid = pm.gid )  
        where hruid = '#{hruid}'"

      custom_sql_query(sql,PlatalDatabaseConnection)
    end

    def get_phones_from_platal(hruid)
      sql = "select pp.*
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_phones AS pp ON (pp.pid=ap.pid)
        where hruid = '#{hruid}'"
      custom_sql_query(sql,PlatalDatabaseConnection)
    end


    # Capitalize firt letter for name. Work even with composed name
    #  "Jean-Paul du bou'd'larue" devient "Jean-Paul Du Bou'd'Larue"
    #  "Jean d'uboudlarue" devient "Jean d'Uboudlarue"
    def formate_name(name)
      # name.split.map{|p| p.split("-").map{|m| m.split("'").map{|n| (n.length > 1 ? n.capitalize : n) }.join("'")}.join("-")}.join(" ")
      name.gsub(/[^\s\-']{02,}/, &:capitalize)

    end


    # Formate le numero de téléphone au format la soce "06.12.34.56.78"
    def formate_phone_for_soce(phone)
      if phone[0..1] ="33"
        formated_phone =  ("0"+phone[2..phone.length]).scan(/../).join(".")
      else
        formated_phone =  ("0"+phone[2..phone.length]).scan(/../).join(".")
      end
    end

    def formate_address_soce(address)
      addresss1 = [
        ( begin address.address_components.select{|n| n["types"].include? "street_number"}.first["long_name"] rescue "" end),
        ( begin address.address_components.select{|n| n["types"].include? "route"}.first["long_name"] rescue "" end)

      ].join(" ")

      addresss2 =""
      postal_code = ( begin address.address_components.select{|n| n["types"].include? "postal_code"}.first["long_name"] rescue "" end )
      city = ( begin address.address_components.select{|n| n["types"].include? "locality"}.first["long_name"] rescue "" end )
      country = ( begin address.address_components.select{|n| n["types"].include? "country"}.first["long_name"] rescue "" end )

      a = ["Adresse 1", addresss1, "Adresse 2",addresss2, "Code postal",postal_code, "Ville",city, "Pays",country]
      return Hash[*a]
    end

    def custom_sql_query(query,connection_model)
      connection = connection_model
      sql = query

      result = connection.connection.execute(sql);
      h=result.each(:as => :hash) do |row| 
        row["44"] 
      end
      #return empty array if no results ( hash full of nil )
      if result.map{|a| a.compact.present? }.include? true 
        return(h)
      else
        return(Array.new())
      end
    end
end
