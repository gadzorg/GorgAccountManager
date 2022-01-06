
class RecoveryService

  attr_reader :session

  def initialize(session)
    @session=session
  end

  def gram_account
    @gram_account||=GramV2Client::Account.find(session.uuid)
  end

  def soce_user
    @soce_user||=Soce::User.find_by(uuid: session.uuid)
  end

  def phone_number
    if soce_user&&soce_user.tel_mobile
      Phonelib.default_country = "FR"
      Phonelib.parse(soce_user.tel_mobile).e164
    end
  end

  def hidden_phone_number
    phone_number&&hide_phone(phone_number)
  end

  def emails
    unless @emails
      list_emails = Array.new

      #Emails from Gram
      list_emails << gram_account.email if gram_account.respond_to?(:email)
      list_emails << gram_account.mail_forwarding if gram_account.respond_to?(:mail_forwarding)
      #Emails from Soce
      list_emails << soce_user.emails_valides if soce_user

      @emails=list_emails.flatten.uniq.reject(&:blank?)
    end
    @emails
  end

  def hidden_emails
    emails.delete_if{|e| e.include?("gadz.fr")}.map{|c|  /gadz.org/.match(c)? "Adresse email prenom.nom@gadz.org": (c.split(".").first c.split(".").size-1).join(".").split("@").map{|a| a.split(".").map{|e| e[0]+e.gsub(/[A-Za-z0-9]/,"*")[1..e.length+1]}.join(".")}.join("@")+"."+c.split(".").last}
  end

  private

    def hide_phone(phone)
      Phonelib.default_country = "FR"
      p=Phonelib.parse(phone)
      temp=p.e164.gsub(/(\d{4})(\d+)(\d{2})/,'\1:middle:\3')
      middle=p.e164.gsub(/(\d{4})(\d+)(\d{2})/,'\2')
      temp.gsub(':middle:',"x"*middle.length)
    end
end
