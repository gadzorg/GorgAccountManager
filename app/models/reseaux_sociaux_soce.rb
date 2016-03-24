class ReseauxSociauxSoce < ActiveRecord::Base
	establish_connection "soce_#{Rails.env}"
	self.table_name = "users_reseaux_sociaux"



	belongs_to :usersoce, foreign_key: "id_user"
	has_one :list_reseaux_sociaux_soce, foreign_key: "id_reseau_social"

	def libelle
		self.list_reseaux_sociaux_soce.libelle
	end
end
