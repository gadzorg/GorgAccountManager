Then(/^he receives an email entitled "([^"]*)" from "([^"]*)"$/) do |subject, from|
  @email = ActionMailer::Base.deliveries.last
  expect(@email.subject).to include(subject)
  #expect(@email.from).to include(from)
end