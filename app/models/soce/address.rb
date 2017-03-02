class Soce::Address < Soce::Base
  self.table_name = "adresses"

  belongs_to :user, foreign_key: "id_user"

  def self.serialize
    hruid = self.first.user.hruid
    sql = "SELECT tel_fixe, fax, adresse_1, adresse_2, code_postal, ville, nompays, adt.libelle  FROM users AS u
    left JOIN adresses AS ad ON (u.id_user=ad.id_user )
    left JOIN pays AS py ON (py.id_pays=ad.id_pays )
    left JOIN liste_adresse_types AS adt ON (adt.id_adresse_type=ad.id_adresse_type )
    where hruid = '#{hruid}'"

    SoceDatabaseConnection.custom_sql_query(sql,SoceDatabaseConnection)
  end

  def self.get_pays_id_from_name(name)
    safe_name=Mysql2::Client.escape(name)
    sql = "SELECT id_pays FROM pays WHERE pays.nom_iso = '#{safe_name}'"
    record=SoceDatabaseConnection.custom_sql_query(sql,SoceDatabaseConnection).first
    record&&record["id_pays"]
  end


end
