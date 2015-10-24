class Uniqlink < ActiveRecord::Base
	def generate_token
		self.token = loop do
			random_token = SecureRandom.urlsafe_base64(nil, false)
			break random_token unless Uniqlink.exists?(token: random_token)
		end
	end

	def set_used
		self.used = true
		self.save
	end

	def used?
		self.used
	end

	def get_url
		return "http://localhost:3000/password_reset/" + self.token
	end

	def usable?
		if !self.used? && self.expire_date >= DateTime.now
			return true
		else
			return false
		end
	end

end
