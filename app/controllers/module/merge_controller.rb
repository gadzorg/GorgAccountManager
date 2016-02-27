class Module::MergeController < ApplicationController

  def user
    hruid = params[:hruid].to_s
    @user_soce = Usersoce.where(hruid: hruid).take
    # info [titre, nom_du_champ, valeur_platal, valeur_soce, status {0=choix possible, 1=ok}]
    info_platal=get_info_from_platal(hruid)

    @info = [
      ["Identifiant", "hruid",   info_platal['hruid'],   @user_soce.hruid,     1],
      ["Prénom", "prenom",  formate_name(info_platal['firstname']),   @user_soce.prenom,     0],
      ["Nom", "nom",   formate_name(info_platal['lastname']),   @user_soce.nom,     0],
      ["Buque", "surnom",  info_platal['buktxt'],  @user_soce.surnom,     0],
      ["Buque Zaloeil", "surnom",  info_platal['bukzal'],  @user_soce.surnom,     0],
      ["Tabagn's", "centre1",  info_platal['tbk'],  @user_soce.centre1,     0],
      ["Email", "email",  info_platal['email'],  @user_soce.email,     0],
      ["Télephone portable", "tel_mobile",  info_platal['search_tel'],  @user_soce.tel_mobile,     0],
      ["Fam's", "famille1",  info_platal['gadz_fams'],  @user_soce.famille1,     0],
      ["Fam's Zaloeil", "famille1",  info_platal['gadz_fams_display'],  "choix2",     0],
      ["Date de naissance", "date_naissance",  info_platal['birthdate'],  @user_soce.date_naissance,     0],
      ["date_declaration_deces", "date_declaration_deces",  info_platal['deathdate'],  @user_soce.date_declaration_deces,     0]
    ]  

  end

  def update_soce_user
  end

  def user_merged
  end

  private
    def get_info_from_platal(hruid)
      @connection = ActiveRecord::Base.establish_connection "platal_#{Rails.env}"

      sql = "select *, hruid, firstname, lastname, pgn.name as buktxt, pgn2.name as bukzal, email, gadz_fams, gadz_fams_display, birthdate, deathdate, search_tel, IF (tbk = 'kin', 'ai', tbk) as tbk
        from accounts as a
        left JOIN account_profiles AS ap ON (ap.uid=a.uid )
        left JOIN profiles AS p ON (p.pid=ap.pid) 
        right JOIN profile_gadz_names AS pgn ON (pgn.pid = p.pid and pgn.type = 'buktxt')
        right JOIN profile_gadz_names AS pgn2 ON (pgn2.pid = p.pid and pgn2.type = 'bukzal')
        left join group_members on a.uid = group_members.uid
        left join groups on group_members.asso_id = groups.id
        left join profile_phones on p.pid = profile_phones.pid
        left join profile_campus_enum on p.campus = profile_campus_enum.id
        where groups.cat = 'Promotions'
        and tel_type = 'mobile'
        and link_type = 'user'
        and hruid = '#{hruid}'"
      @result = @connection.connection.execute(sql);
      @result.each(:as => :hash) do |row| 
        row["user"] 
      end
      @result.first

    end

    # Capitalise firt letter for name. Work even with composed name
    #  "Jean-Paul du bou'd'larue" devient "Jean-Paul Du Bou'd'Larue"
    #  "Jean d'uboudlarue" devient "Jean d'Uboudlarue"
    def formate_name(name)
      name.split.map{|p| p.split("-").map{|m| m.split("'").map{|n| (n.length > 1 ? n.capitalize : n) }.join("'")}.join("-")}.join(" ")
    end
end
