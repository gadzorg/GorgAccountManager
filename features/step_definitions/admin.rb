Given(/^a logged admin$/) do
  @me = FactoryBot.create(:user, :admin)

  step "I'm logged in"
end

And(/^within admin dropdown he clicks "([^"]*)" button$/) do |title|
  step "he clicks \"Administration\" button"

  within "#dropdown_menuadministration" do
    click_link_or_button(title)
  end
end
