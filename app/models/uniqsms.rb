class Uniqsms < ActiveRecord::Base
	before_save :default_values
	def default_values
	    self.check_count ||= 0
	end

	def generate_token
		self.token = loop do
			random_token = SecureRandom.random_number.to_s[4..9]
			break random_token unless Uniqsms.exists?(token: random_token)
		end
	end

	def set_used
		self.used = true
		self.save
	end

	def used?
		self.used
	end

	def get_message
		return "Ton code de récupération est: " + self.token
	end

	def usable?
		if !self.used? && self.expire_date >= DateTime.now
			return true
		else
			return false
		end
	end

	def self.generate_for_uuid(uuid)
		new_link = self.new(
				uuid: uuid,
				used: false,
				expire_date: DateTime.now + 10.minutes # on definit la durée de vie d'un token à 1 jour
		)
		new_link.generate_token
		new_link.save
		return new_link
	end

end
