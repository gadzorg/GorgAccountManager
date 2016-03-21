class Module::MergeController < ApplicationController

  require 'fuzzystringmatch'
  require 'linkedin_scraper'

  def user
    # select current user if no params
    if params[:hruid].present?
      hruid = params[:hruid]
    else
      @user=current_user
      hruid = @user.hruid if @user.present?
    end
    authorize! :read, @user

    @user_soce = Usersoce.where(hruid: hruid).take
    # info [titre, nom_du_champ, valeur_platal, valeur_soce, status {0=choix possible, 1=ok}]
    info_platal=get_info_from_platal(hruid)

    @info = [
      ["Identifiant", "hruid",   info_platal['hruid'],   @user_soce.hruid,     1],
      ["Prénom", "prenom",  formate_name(info_platal['firstname']),   @user_soce.prenom,     0],
      ["Nom", "nom",   formate_name(info_platal['lastname']),   @user_soce.nom,     0],
      ["Buque", "buktxt",  info_platal['buktxt'],  @user_soce.surnom,     0],
      ["Buque Zaloeil", "bukzal",  info_platal['bukzal'],  "champ à ajouter dans bdd SOCE",     0],
      ["Tabagn's", "centre1",  info_platal['tbk'],  @user_soce.centre1.to_s.gsub(/[0-9]/, "1" => "ch", "2" => "an", "3" => "ai", "4" => "cl", "5" => "li", "6" => "pa", "7" => "bo", "8" => "ka", "9" => "me", "10" => "am"),     0],
      ["Email", "email",  info_platal['email'],  @user_soce.email,     0],
      ["Télephone portable", "tel_mobile",  info_platal['search_tel'],  @user_soce.tel_mobile,     0],
      ["Fam's", "famille1",  info_platal['gadz_fams'],  @user_soce.famille1,     0],
      ["Fam's Zaloeil", "famille1zal",  info_platal['gadz_fams_display'],  "champ à ajouter dans bdd SOCE",     0],
      ["Date de naissance", "date_naissance",  info_platal['birthdate'].strftime("%d %b %Y"),  @user_soce.date_naissance.strftime("%d %b %Y"),     0],
      ["date_declaration_deces", "date_declaration_deces",  info_platal['deathdate'],  @user_soce.date_declaration_deces,     0]
    ]

    @phones_platal = get_phones_from_platal(hruid)

    @addresses_soce=get_addresses_from_soce(hruid)

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
    @socials_soce = get_socials_from_soce(hruid)


    @jobs_platal = get_jobs_from_platal(hruid).sort_by{ |k| k["entry_year"]}.reverse
    @jobs_soce = get_jobs_from_soce(hruid)

    @diploma_platal = get_diploma_from_platal(hruid)
    @diploma_soce = get_diploma_from_soce(hruid)

    @medal_platal = get_medal_from_platal(hruid)
    @medal_soce = get_medal_from_soce(hruid)

    #linkedintest
    linkedin_hash = @socials_platal.select{|n| (n["name"].include? "LinkedIn") if n["name"].present?}.first if @socials_platal.present?
    if linkedin_hash.present?
      linkedin_url = linkedin_hash["link"].gsub("%s",linkedin_hash["address"])
      @linkedin_profile = Linkedin::Profile.get_profile(linkedin_url)
    end

  end

  def update_soce_user
  end

  def user_merged
  end

  private
    def get_info_from_platal(hruid)
      connection = PlatalDatabaseConnection

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
      @result = connection.connection.execute(sql);
      @result.each(:as => :hash) do |row| 
        row["user"] 
      end

      @result.first

    end

    def get_addresses_from_platal(hruid)
      connection = PlatalDatabaseConnection

      sql = "select formatted_address, postalText, pa.type, pa.flags
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_addresses AS pa ON (pa.pid=ap.pid)
        where hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);
      

      @result.each(:as => :hash) do |row| 
        row["adresses"] 
      end

    end
    def get_jobs_from_platal(hruid)
      connection = PlatalDatabaseConnection

      sql = "select pj.description AS job_desc, pj.email, pj.url AS job_url, entry_year, pje.name AS cpny_name, pje.url, NAF_code, pje.description AS cpny_desc, jte.name, jte.full_name
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_job AS pj ON (pj.pid=ap.pid)
        left JOIN profile_job_enum AS pje ON (pje.id=pj.jobid)
        left JOIN profile_job_term AS jt  ON (jt.pid = pj.pid AND jt.jid = pj.id)
        LEFT JOIN  profile_job_term_enum AS jte USING(jtid)
        where hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);
      

      @result.each(:as => :hash) do |row| 
        row["jobs"] 
      end

    end

    def get_socials_from_platal(hruid)
      connection = PlatalDatabaseConnection

      sql = "select pn.*, pne.*
        FROM accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_networking AS pn ON ap.pid = pn.pid
        left JOIN profile_networking_enum AS pne ON pn.nwid = pne.nwid
        where hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);
      @result.each(:as => :hash) do |row| 
        row["socials"] 
      end

    end

    def get_diploma_from_platal(hruid)
      connection = PlatalDatabaseConnection

      sql = "Select *
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_education AS pe ON (ap.pid=pe.pid ) 
        left JOIN profile_education_enum AS pee ON (pee.id=pe.eduid )
        where not pee.id = 28  
        and hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);
      @result.each(:as => :hash) do |row| 
        row["diploma"] 
      end

    end

    def get_medal_from_platal(hruid)
      connection = PlatalDatabaseConnection

      sql = "Select pme.type, pme.text AS medal_text, pmge.text AS medal_grade_text
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_medals AS pm ON (ap.pid=pm.pid ) 
        left JOIN profile_medal_enum AS pme ON (pme.id=pm.mid ) 
        left JOIN profile_medal_grade_enum AS pmge ON (pmge.mid=pm.mid and pmge.gid = pm.gid )  
        where hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);
      @result.each(:as => :hash) do |row| 
        row["medal"] 
      end

    end

    def get_phones_from_platal(hruid)
      connection = PlatalDatabaseConnection

      sql = "select pp.*
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profile_phones AS pp ON (pp.pid=ap.pid)
        where hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);
      @result.each(:as => :hash) do |row| 
        row["phone"] 
      end

    end

    


    

    def get_addresses_from_soce(hruid)
      connection = SoceDatabaseConnection

      sql = "SELECT tel_fixe, fax, adresse_1, adresse_2, code_postal, ville, nompays, adt.libelle  FROM users AS u
        left JOIN adresses AS ad ON (u.id_user=ad.id_user )
        left JOIN pays AS py ON (py.id_pays=ad.id_pays )
        left JOIN liste_adresse_types AS adt ON (adt.id_adresse_type=ad.id_adresse_type )
        where hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);
      @result.each(:as => :hash) do |row| 
        row["adresses"] 
      end

    end

    def get_jobs_from_soce(hruid)
      connection = SoceDatabaseConnection

      sql = "SELECT e.*, p.date_debut, p.date_fin, p.tel_direct, p.tel_standard, p.email, p.gsm, p.adresse, p.adresse2, p.adresse3, p.code_postal AS code_postal_entreprise, p.ville AS ville_entreprise, p.pays AS pays_entreprise, p.fax, p.id_etat_validation
, py.*, f.* FROM users 
left join postes AS p on users.id_user = p.id_user
left join entreprises AS e on e.id_entreprise = p.id_entreprise
left join pays AS py on e.id_pays = py.id_pays
left join liste_fonctions AS f on f.id_fonction = p.id_fonction
        where hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);    
      @result.each(:as => :hash) do |row| 
        row["jobs"] 
      end

    end

    def get_socials_from_soce(hruid)
      connection = SoceDatabaseConnection

      sql = "SELECT urs.*, lrs.*
        FROM users as u
        left join users_reseaux_sociaux as urs on u.id_user = urs.id_user
        left join liste_reseaux_sociaux as lrs on lrs.id_reseau_social = urs.id_reseau_social
        where hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);
      @result.each(:as => :hash) do |row| 
        row["socials"] 
      end

    end
    def get_diploma_from_soce(hruid)
      connection = SoceDatabaseConnection

      sql = "SELECT ud.*
        FROM users as u
        left join users_diplomes as ud on u.id_user = ud.id_user
        where hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);
      @result.each(:as => :hash) do |row| 
        row["diploma"] 
      end

    end

    def get_medal_from_soce(hruid)
      connection = SoceDatabaseConnection

      sql = "SELECT m.*, annee
        FROM users as u
        left join liens_users_medailles as um on um.id_user = u.id_user
        left join medailles as m on m.id_medaille = um.id_medaille
        where hruid = '#{hruid}'"
      @result = connection.connection.execute(sql);
      @result.each(:as => :hash) do |row| 
        row["medal"] 
      end

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

      return [addresss1, addresss2, postal_code, city, country]

    end
end
