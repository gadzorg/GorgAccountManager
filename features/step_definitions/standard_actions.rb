When(/^he clicks "([^"]*)" button$/) do |title|
  click_link_or_button(title)
end

Then(/^the page has button "([^"]*)"$/) do |title|
  expect(page).to have_css("a[title=\"#{title}\"],input[type=\"submit\"][value=\"#{title}\"]")
end


When(/^he fills "([^"]*)" with "([^"]*)"$/) do |title,content|
  fill_in(title, with: content)
end

And(/^he sees "([^"]*)"$/) do |arg|
  expect(page).to have_content(arg)
end