And(/^There is no gorgmail account with email address "([^"]*)"$/) do |arg|
  GorgmailApiMocker.new.mock_search_query(arg,nil)
end