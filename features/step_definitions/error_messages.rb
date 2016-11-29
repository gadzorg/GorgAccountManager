def flash_messages
  JSON.parse(Capybara.current_session.driver.request.cookies["flash"])
end

And(/^a "([^"]*)" message containing "([^"]*)" appears$/) do |type,message|
  matches=flash_messages.select{|e|e[0]==type&&e[1].include?(message)}

  expect(matches.count).to be > 0
end

