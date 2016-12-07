require 'phonelib'

class SmsService

  attr_reader :recipient, :error
  attr_accessor :from


  BASE_URL="https://www.ovh.com/cgi-bin/sms/http2sms.cgi"
  DEFAULT_FROM=Rails.application.secrets.ovh_sms_from
  OVH_ACCOUNT=Rails.application.secrets.ovh_sms_account
  OVH_LOGIN=Rails.application.secrets.ovh_sms_login
  OVH_PASSWORD=Rails.application.secrets.ovh_sms_password

  def initialize(recipient, opts={})
    @recipient=parse_phone_number(recipient)
    @from=opts[:from]||DEFAULT_FROM
  end

  def send_recovery_message(code)
    send_message("Ton code de validation Gadz.org est: #{code.to_s}")
  end

  def send_message(message)
    uri=uri_for_message(message)
    Rails.logger.info("Send SMS : '#{message}' to #{recipient.to_s}")

    res=JSON.parse(Net::HTTP.get_response(uri).body)
    #http://guides.ovh.com/Http2Sms for responses examples

    Rails.logger.info("OVH API response : #{res.to_json}")
    if res['status'] >= 100 && res['status'] < 200
      true
    else
      @error=res['message']
      false
    end
  end

  private

  def parse_phone_number(number)
    Phonelib.default_country = "FR"
    Phonelib.parse(number).e164.gsub('+','00')
  end

  def uri_for_message(message)
    uri=URI.parse(BASE_URL)
    uri.query={
        account:OVH_ACCOUNT,
        login:OVH_LOGIN,
        password:OVH_PASSWORD,
        from:from,
        to:@recipient,
        message:message.to_s,
        noStop: 1,
        contentType:'text/json'
    }.to_query
    uri
  end


end