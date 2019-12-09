And(/^I'm logged in$/) do
  visit new_user_session_path
  fill_in "user_email", with: @me.email
  fill_in "user_password", with: @me.password
  click_button "Connexion"
end
