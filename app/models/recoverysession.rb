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

  def self.initialize_for(uuid,opts={})
    s=self.new
    s.uuid = uuid
    if opts[:token]
      s.token=opts[:token]
    else
      s.generate_token
    end
    opts[:expire_date]||= DateTime.now + 15.minute # on definit la durée de vie par défaut d'un token à 15 minutes
    s.expire_date = opts[:expire_date]
    s.save
    return s
  end

end