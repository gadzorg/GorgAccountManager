When(/^he clicks "([^"]*)" button$/) { |title| click_link_or_button(title) }

Then(/^the page has button "([^"]*)"$/) do |title|
  expect(page).to have_css(
    "a[title=\"#{title}\"],input[type=\"submit\"][value=\"#{title}\"]",
  )
end

Then(/^the page has css "(.+)"$/) do |selector|
  expect(page).to have_css(selector)
end

When(/^he fills "([^"]*)" with "([^"]*)"$/) do |title, content|
  fill_in(title, with: content)
end

And(/^he sees "([^"]*)"$/) { |arg| expect(page).to have_content(arg) }

And(/^field "([^"]*)" is filled with "([^"]*)"$/) do |field, value|
  expect(page).to have_field(field, with: value)
end
