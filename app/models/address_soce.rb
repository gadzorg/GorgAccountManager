class AddressSoce < ActiveRecord::Base
	establish_connection "soce_#{Rails.env}"
	self.table_name = "adresses"



	belongs_to :usersoce, foreign_key: "id_user"

	def self.serialize
		hruid = self.first.usersoce.hruid
		sql = "SELECT *,e.*, p.date_debut, p.date_fin, p.tel_direct, p.tel_standard, p.email, p.gsm, p.adresse, p.adresse2, p.adresse3, p.code_postal AS code_postal_entreprise, p.ville AS ville_entreprise, p.pays AS pays_entreprise, p.fax, p.id_etat_validation, py.*, f.* FROM users 
        left join postes AS p on users.id_user = p.id_user
        left join entreprises AS e on e.id_entreprise = p.id_entreprise
        left join pays AS py on e.id_pays = py.id_pays
        left join liste_fonctions AS f on f.id_fonction = p.id_fonction
                where hruid = '#{hruid}'"

        SoceDatabaseConnection.custom_sql_query(sql,SoceDatabaseConnection)
	end


end
