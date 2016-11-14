
class SmsService

  def self.phone_parse(phone)
    if phone[0] == "+"
      internat_phone = phone.gsub("+","00")
    elsif phone.length == 14 || phone.length == 10 #10 et les points ou sans
      internat_phone = "0033"+phone.gsub(".","").split(//).join[1..9]
    elsif phone.length > 15 # pour les numeros de tel étranger 0033.123.456.789 avec la possibilité d'avoir un indicatif à 3 chiffres et des point tous les 2 chiffre
      internat_phone = phone.gsub(".","")
    else
      return false
    end
    return internat_phone
  end

  def self.send_sms(phone_number,code)
    base_url = "https://www.ovh.com/cgi-bin/sms/http2sms.cgi?"
    account = Rails.application.secrets.ovh_sms_account
    login = Rails.application.secrets.ovh_sms_login
    password = Rails.application.secrets.ovh_sms_password
    from = Rails.application.secrets.ovh_sms_from
    message = "Ton code de validation Gadz.org est: " + code

    full_url = base_url + "account=" + account + "&login=" + login + "&password=" + password + "&from=" + from + "&to=" + phone_number + "&message=" + message + "&noStop=1"

    # on envoie la requete get en https
    # TODO il serait bien de regarder le code de réponse
    encoded_url = URI.encode(full_url)
    uri = URI.parse(encoded_url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'

    http.start do |h|
      h.request Net::HTTP::Get.new(uri.request_uri)
      Rails.logger.info "#--------------------------------------------------------------------URL"
      Rails.logger.info(h)
    end
  end

end