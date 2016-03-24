class Soce::User < Soce::Base
	# establish_connection "soce_#{Rails.env}"
	self.table_name = "users"

	has_many :reseaux_sociaux, foreign_key: "id_user"
	has_many :job, foreign_key: "id_user"
	has_many :address, foreign_key: "id_user"
	has_many :diploma, foreign_key: "id_user"
	has_many :medal, foreign_key: "id_user"

	def emails_valides
		email_list = Array.new
		email_list.push(self.email) if email_valide = "1"
		email_list.push(self.email_secondaire) if !email_secondaire.nil?

		return email_list
	end
end
