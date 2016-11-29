And(/^([^"]*) has initiated a recovery session(?: with token "([^"]*)")?$/) do |name,token|
  @recovery_session=Recoverysession.new
  @recovery_session.uuid = @uuid
  @recovery_session.expire_date = DateTime.now + 15.minute # on definit la durée de vie d'un token à 15 minutes
  if token
    @recovery_session.token=token
  else
    @recovery_session.generate_token
  end
  @recovery_session.save
end

Given(/^Blaked has initiated a recovery session expiring 1 minute ago$/) do
  @recovery_session=Recoverysession.new
  @recovery_session.uuid = @uuid
  @recovery_session.expire_date = DateTime.now - 1.minute
  @recovery_session.generate_token
  @recovery_session.save
end