When(/^he connect to the password recovery entry-point$/) do
  visit('/recovery')
end

Then(/^he is asked to try again$/) do
  expect(page).to have_content("Nous n'avons pas pu t'identifier")
end

Then(/^he is redirected to choose his recovering method$/) do
  expect(page).to have_current_path(/recovery_step1\/(.*)/)
end

When(/^he visits step 1 of the recovery session(?: "([^"]*)")?$/) do |token|
  token||=@recovery_session.token
  visit(recovery_step1_path(:token_session => token))
end

Then(/^he is redirected to the password recovery entry\-point$/) do
  expect(page).to have_current_path("/recovery")
end

And(/^he see his email addresses$/) do
  expect(page).to have_content('@gadz.org')
end

And(/^this emails contains a link to recover its session$/) do
  @email = ActionMailer::Base.deliveries.last
  @email.body.parts.each do |p|
    expect(p.body.decoded).to match(/password_reset\/[a-zA-Z0-9_-]+/)
  end
end

And(/^he has a recovery session recovering link$/) do
  @uniq_link=Uniqlink.generate_for_uuid(@uuid)
end

And(/^he is visiting his recovery session recovering link$/) do
  visit(password_change_path(token: @uniq_link.token))
end


And(/^he visits SMS confirmation page$/) do
  visit("/recovery_sms?token_session=#{@recovery_session.token}")
end

Then(/^he is redirected to the SMS confirmation page$/) do
  expect(page).to have_current_path("/recovery_sms?token_session=#{@recovery_session.token}")
end

And(/^he is redirected to his recovery link$/) do

  regex=/\/password_reset\/([a-zA-Z0-9_-]+)/
  expect(page).to have_current_path(regex) #On vérifie qu'on est sur la bonne page

  token=regex.match(page.current_path)[1]
  expect(Uniqlink.find_by(token: token).uuid).to eq(@uuid) #On vérifie qu'il correspond bien au user
end

Then(/^he is redirected to recovery entry\-point$/) do
  expect(page).to have_current_path(/\/recovery(\?.*)?/)
end