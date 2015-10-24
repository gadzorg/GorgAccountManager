class Usersoce < ActiveRecord::Base
	establish_connection "soce_#{Rails.env}"
	self.table_name = "users"

	# sql = 'SELECT * FROM int_anakrys_soce.users where hruid = "dorian.becker.2011";'
	# @result = @connection.connection.execute(sql);
	# @result.each(:as => :hash) do |row|
	# puts row["email"] 
	# end
	def emails_valides
		email_list = Array.new
		email_list.push(self.email) if email_valide = "1"
		email_list.push(self.email_secondaire) if !email_secondaire.nil?

		return email_list
	end
end
