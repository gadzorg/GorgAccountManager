class PlatalDatabaseConnection < ActiveRecord::Base
	establish_connection ENV['PLATAL_DATABASE_URL']||"platal_#{Rails.env}"

	def self.abstract_class?
		true
	end

end
