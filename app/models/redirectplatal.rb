class Redirectplatal < ActiveRecord::Base
	establish_connection ENV['PLATAL_DATABASE_URL']||"platal_#{Rails.env}"
	self.table_name = "email_redirect_account"
	self.inheritance_column = :type_foo #parce qu'il y a une colonne type dans g6dat et que c'est interdit par AR.
	self.primary_key = "redirect"

	belongs_to :userplatal, foreign_key: "uid"
end
