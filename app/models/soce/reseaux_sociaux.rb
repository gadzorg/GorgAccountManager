class Soce::ReseauxSociaux < Soce::Base
	self.table_name = "users_reseaux_sociaux"



	belongs_to :user, foreign_key: "id_user"
	has_one :list_reseaux_sociaux, foreign_key: "id_reseau_social"

	def libelle
		self.list_reseaux_sociaux.libelle
	end
end
