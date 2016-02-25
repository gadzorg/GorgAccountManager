class Module::MergeController < ApplicationController

  def user
    hruid = params[:hruid].to_s
    @user_soce = Usersoce.where(hruid: hruid).take
    # info [nom_du_champ, valeur_platal, valeur_soce, status {0=choix possible, 1=ok}]
    info_platal=get_info_from_platal(hruid)

    @info = [
      ["hruid",   info_platal['hruid'],   "choix2",     1],
      ["prenom",   info_platal['firstname'],   @user_soce.prenom,     0],
      ["nom",   info_platal['lastname'],   @user_soce.nom,     0],
      ["email",   "choix1",               "choix2",     0],
      ["surnom",  info_platal['buktxt'],  "choix2",     0]
    ]

    

  end

  private
  def get_info_from_platal(hruid)
    @connection = ActiveRecord::Base.establish_connection "platal_#{Rails.env}"

    sql = "select hruid, firstname, lastname, pgn.name as buktxt, pgn2.name as bukzal
      from accounts as a
      left JOIN account_profiles AS ap ON (ap.uid=a.uid )
      left JOIN profiles AS p ON (p.pid=ap.pid)
      right JOIN profile_gadz_names AS pgn ON (pgn.pid = p.pid and pgn.type = 'buktxt')
      right JOIN profile_gadz_names AS pgn2 ON (pgn2.pid = p.pid and pgn2.type = 'bukzal')
      where hruid = '#{hruid}'"
    @result = @connection.connection.execute(sql);
    @result.each(:as => :hash) do |row| 
      row["user"] 
    end
    @result.first

  end
end
