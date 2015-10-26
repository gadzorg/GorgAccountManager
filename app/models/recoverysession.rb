class Recoverysession < ActiveRecord::Base
	def generate_token
		self.token = loop do
			random_token = SecureRandom.urlsafe_base64(nil, false)
			break random_token unless Recoverysession.exists?(token: random_token)
		end
	end

	def usable?
		if self.expire_date >= DateTime.now
			return true
		else
			return false
		end
	end

	def add_sms_check
		sms=Uniqsms.where(hruid: self.hruid).select{|e| e.usable?}
		sms.map{|s| s.check_count +=1; s.save}
	end


end