class PlatalDatabaseConnection < ActiveRecord::Base
	establish_connection "platal_#{Rails.env}"

	def self.abstract_class?
		true
	end

end
