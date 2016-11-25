When(/^he search "([^"]*)" in password recovery$/) do |arg|
  fill_in('user_hruid', with: 'blaked@gadz.org')
  click_button('Recuperer')
end

When(/^he connect to the password recovery system$/) do
  visit('/recovery')
end

Then(/^he is asked to try again$/) do
  expect(page).to have_current_path("/recovery?retry=true")
  expect(page).to have_content("Nous n'avons pas pu t'identifier")
end

Then(/^he is redirected to choose his recovering method$/) do
  expect(page).to have_current_path(/recovery_step1\/(.*)/)
end