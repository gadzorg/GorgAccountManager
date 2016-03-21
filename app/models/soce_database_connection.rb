class SoceDatabaseConnection < ActiveRecord::Base
	establish_connection "soce_#{Rails.env}"

	def self.abstract_class?
		true
	end

end
