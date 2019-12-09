class Recoverysession < ApplicationRecord

  MAX_SMS_ATTEMPTS=5
  SESSION_TTL=15.minute

  class TooManySmsAttempts < StandardError;end

	def generate_token
		self.token = loop do
			random_token = SecureRandom.urlsafe_base64(nil, false)
			break random_token unless Recoverysession.exists?(token: random_token)
		end
	end

	def usable?
		self.expire_date >= DateTime.now
  end

  def add_sms_count
    self.sms_count = self.sms_count.to_i+1
    save
  end

	def add_sms_check
    self.sms_check_count=self.sms_check_count.to_i+1
    save
  end

  def set_expired
    self.expire_date = DateTime.now-1.second
    save
  end

  def check_sms_token(uniq_sms)
    add_sms_check
    if sms_check_count>MAX_SMS_ATTEMPTS
      set_expired
      raise TooManySmsAttempts
    end
    uniq_sms&&uniq_sms.usable? && self.uuid==uniq_sms.uuid
  end

  def self.initialize_for(uuid,opts={})
    s=self.new
    s.uuid = uuid
    if opts[:token]
      s.token=opts[:token]
    else
      s.generate_token
    end
    opts[:expire_date]||= DateTime.now + SESSION_TTL # on definit la durée de vie par défaut d'un token à 15 minutes
    s.expire_date = opts[:expire_date]
    s.save
    return s
  end

end