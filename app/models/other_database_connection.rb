class OtherDatabaseConnection < ActiveRecord::Base
	# establish_connection ENV['PLATAL_DATABASE_URL']||"platal_#{Rails.env}".to_sym

	def self.abstract_class?
		true
	end

end
