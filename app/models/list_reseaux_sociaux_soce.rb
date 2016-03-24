class ListReseauxSociauxSoce < ActiveRecord::Base
	establish_connection "soce_#{Rails.env}"
	self.table_name = "liste_reseaux_sociaux"

	belongs_to :reseaux_sociaux_soce, foreign_key: "id_reseau_social"
end
