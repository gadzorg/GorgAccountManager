class Soce::ListReseauxSociaux < Soce::Base
	self.table_name = "liste_reseaux_sociaux"

	belongs_to :reseaux_sociaux, foreign_key: "id_reseau_social"
end
