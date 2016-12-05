def flash_messages
  raw_flash=Capybara.current_session.driver.request.cookies["flash"]
  raw_flash ? JSON.parse(Capybara.current_session.driver.request.cookies["flash"].to_s) : []
end

And(/^a "([^"]*)" message containing "([^"]*)" appears$/) do |type,message|
  matches=flash_messages.select{|e|e[0].to_s==type&&e[1].to_s.include?(message)}
  expect(matches.count).to eq(1)
end

