And(/^([^"]*) has initiated a recovery session(?: with token "([^"]*)")?$/) do |name,token|
  @recovery_session=Recoverysession.initialize_for(@uuid, token:token)
end

Given(/^Blaked has initiated a recovery session expiring 1 minute ago$/) do
  @recovery_session=Recoverysession.initialize_for(@uuid, expire_date:(DateTime.now - 1.minute))
end