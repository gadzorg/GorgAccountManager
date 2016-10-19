
class RecoveryService

  def self.get_emails(user_from_gram,soce_user)
    list_emails = Array.new
    list_emails.push(user_from_gram.mail_forwarding) if user_from_gram.respond_to?(:mail_forwarding)

    #@list_emails.push(user_from_gram.mail_alias)
    list_emails.push(user_from_gram.email) if user_from_gram.email.present? && user_from_gram.respond_to?(:email)
    #list_emails.push(user_from_gram.email_forge) if user_from_gram.email_forge.present? && user_from_gram.respond_to?(:email_forge)
    #email du site soce
    list_emails.push(soce_user.emails_valides) unless soce_user.blank?

    list_emails = list_emails.flatten.uniq
    list_emails = list_emails.reject(&:blank?) #on supprime les emails vides

    # on supprime les adresses en gadz.org pour éviter d'avoir des doublons
    # je l'ai commenté parce que les emails du gram ne sont pas forcement à jour
    # @list_emails = @list_emails.drop_while{|e| /gadz.org/.match(e)}

    #@list_emails_to_display = @list_emails.map{|c|  /gadz/.match(c)? "Adresse @gadz.org": c[0]+c.gsub(/[A-Za-z0-9]/,"*")[1..c.length-3]+c[c.length-2..c.length-1]}
  end
end