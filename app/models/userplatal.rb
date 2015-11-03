class Userplatal < ActiveRecord::Base
	establish_connection "platal_#{Rails.env}"
	self.table_name = "accounts"
	self.inheritance_column = :type_bar #parce qu'il y a une colonne type dans g6dat et que c'est interdit par AR.

	has_many :redirectplatal, foreign_key: "uid"
end
