def gram_account_mocked (hash={})
  @gen_gram_account={
      "uuid"=>"559bb0aa-ddac-4607-ad41-7e520ee40819",
      "hruid"=>"alexandre.narbonne.2011",
      "firstname"=>"Alexandre",
      "lastname"=>"NARBONNE",
      "id_soce"=>"84189",
      "enable"=>"TRUE",
      "id"=>85189,
      "uid_number"=>85189,
      "gid_number"=>85189,
      "home_directory"=>"/nonexistant",
      "alias"=>["alexandre.narbonne.2011", "84189", "84189J"],
      "password"=>"Not Display",
      "email"=>"alexandre.narbonne",
      "email_forge"=>"alexandre.narbonne@gadz.org",
      "birthdate"=>"1987-09-17 00:00:00",
      "login_validation_check"=>"CGU=2015-06-04;",
      "description"=>"Agoram inscription - via module register - creation 2015-06-04 11:32:48",
      "entities"=>["comptes", "gram"],
      "is_gadz"=>"true"
  }

  @gen_gram_account.merge(hash)
end

Given(/^([a-zA-Z]+) has a Gram Account with ((?:[a-zA-Z_]+ ["'][^"']*["'](?:, )?)*)$/) do |firstname,raw_attrs|

  @uuid||="559bb0aa-ddac-4607-ad41-7e520ee40819"

  attrs=raw_attrs.split(",").map do |e|
    match=/([a-zA-Z_]+) "([^"]*)"/.match(e)
    [match[1],match[2]]
  end.to_h

  @mocked_gram_account=gram_account_mocked({'uuid'=>@uuid,'firstname' => firstname}.merge(attrs))
  ActiveResource::HttpMock.respond_to do |mock|
    if attrs["email"]
      mock.get "/api/v2/accounts.json?email=#{CGI.escape(attrs["email"])}", authorization_header, [@mocked_gram_account].to_json, 200
    end
    mock.get "/api/v2/accounts/559bb0aa-ddac-4607-ad41-7e520ee40819.json", authorization_header, @mocked_gram_account.to_json, 200
  end

  #Here is saved the request to change password
  @pairs ||= {}
  update_password_req=ActiveResource::Request.new(:put, '/api/v2/accounts/559bb0aa-ddac-4607-ad41-7e520ee40819.json', '{"uuid":"559bb0aa-ddac-4607-ad41-7e520ee40819","hruid":"alexandre.narbonne.2011","firstname":"Blaked","lastname":"NARBONNE","id_soce":"84189","enable":"TRUE","id":85189,"uid_number":85189,"gid_number":85189,"home_directory":"/nonexistant","alias":["alexandre.narbonne.2011","84189","84189J"],"password":"6b60dbe969d518f99bfaea4d308fb77a6cb56de5","email":"blaked@gadz.org","email_forge":"alexandre.narbonne@gadz.org","birthdate":"1987-09-17 00:00:00","login_validation_check":"CGU=2015-06-04;","description":"Agoram inscription - via module register - creation 2015-06-04 11:32:48","entities":["comptes","gram"],"is_gadz":"true"}', authorization_header.merge("Content-Type" => "application/json"))
  update_password_resp = ActiveResource::Response.new("", 201, {"Location" => "/api/v2/accounts/559bb0aa-ddac-4607-ad41-7e520ee40819.json"})

  @pairs = @pairs.merge({
      update_password_req => update_password_resp
  })



  ActiveResource::HttpMock.respond_to(@pairs, false)
end




And(/^There is no gram account with email address "([^"]*)"$/) do |email_address|
  json_auth_headers = authorization_header.merge("Accept" => "application/json")

  ActiveResource::HttpMock.respond_to do |mock|
    mock.get "/api/v2/accounts.json?email=#{CGI.escape(email_address)}", json_auth_headers, [].to_json, 200
    mock.get "/api/v2/accounts.json?hruid=#{CGI.escape(email_address)}", json_auth_headers, [].to_json, 200
    mock.get "/api/v2/accounts.json?id_soce=", json_auth_headers, [].to_json, 200
  end
end

Then(/^the hashed password "([^"]*)" is sent on his GrAM Account$/) do |hashed_password|
expect(ActiveResource::HttpMock.requests.any?{|r| r.method==:put&&r.path=="/api/v2/accounts/#{@uuid}.json"&&JSON.parse(r.body)["password"]==hashed_password}).to be true

end
