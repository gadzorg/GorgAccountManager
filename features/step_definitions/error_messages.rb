def flash_messages
  JSON.parse(Capybara.current_session.driver.request.cookies["flash"])
end

And(/^an error message containing "([^"]*)" appears$/) do |message|
  matches=flash_messages.select{|e|e[0]=="error"&&e[1].include?(message)}

  expect(matches.count).to be > 0
end

And(/^a notice message containing "([^"]*)" appears$/) do |message|
  matches=flash_messages.select{|e|e[0]=="notice"&&e[1].include?(message)}

  expect(matches.count).to be > 0
end

