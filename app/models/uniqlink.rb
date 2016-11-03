class Uniqlink < ActiveRecord::Base
	before_save :default_values
	def default_values
		self.inscription ||= false
		true
	end

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
		return Configurable[:site_url] + "password_reset/" + self.token
	end
	def get_inscription_url
		return Configurable[:site_url] + "recovery_inscription/" + self.token
	end

	def usable?
		if !self.used? && self.inscription = true || !self.used? && self.expire_date >= DateTime.now
			return true
		else
			return false
		end
	end

	def new_inscription_link(hruid, email)
		self.token = self.generate_token
		self.inscription = true
		self.email = email
	end

	def self.generate_for_uuid(uuid)
		new_link = Uniqlink.new(
			uuid: uuid,
			used: false,
			inscription: false,
			expire_date: DateTime.now + 1.day # on definit la durée de vie d'un token à 1 jour
		)
		new_link.generate_token
		new_link.save
		return new_link
	end

end
