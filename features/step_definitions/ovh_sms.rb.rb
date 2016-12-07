Then(/^an SMS is sent$/) do
  expect(a_request(:get, /https:\/\/www\.ovh\.com\/cgi-bin\/sms\/http2sms\.cgi.*/)).to have_been_made.once
end


Given(/^he received the recovery code "([^"]*)"$/) do |code|
  @recovery_sms=Uniqsms.new
  @recovery_sms.token= code
  @recovery_sms.uuid = @uuid
  @recovery_sms.expire_date = DateTime.now + 10.minute # on definit la durée de vie d'un token à 10 minutes
  @recovery_sms.save
end

And(/^this SMS is sent from "([^"]*)"$/) do |arg|
  expect(
      a_request(:get, /https:\/\/www\.ovh\.com\/cgi-bin\/sms\/http2sms\.cgi.*/).with(query: hash_including(from: arg))
  ).to have_been_made.once

end

And(/^this SMS contains a confirmation code$/) do
  expect(a_request(:get, /^https:\/\/www\.ovh\.com\/cgi-bin\/sms\/http2sms\.cgi\?.*message=[^&]*([0-9]{6}).*$/)).to have_been_made.once
end