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

Given(/^([a-zA-Z]+) has a Gram Account with email address equal to "([^"]*)"$/) do |firstname,email_address|
  mocked_account=gram_account_mocked({"uuid"=>"559bb0aa-ddac-4607-ad41-7e520ee40819",'firstname' => firstname ,'email' => email_address})
  ActiveResource::HttpMock.respond_to do |mock|
    mock.get "/api/v2/accounts.json?email=#{URI.escape(email_address,"@")}", {"Authorization"=>"Basic cmF0YXRvc2s6dGVzdF9wYXNz",'Accept' => 'application/json'}, [mocked_account].to_json, 200
    mock.get "/api/v2/accounts/559bb0aa-ddac-4607-ad41-7e520ee40819.json", {"Authorization"=>"Basic cmF0YXRvc2s6dGVzdF9wYXNz",'Accept' => 'application/json'}, mocked_account.to_json, 200
  end
end


And(/^There is no gram account with email address "([^"]*)"$/) do |email_address|
  ActiveResource::HttpMock.respond_to do |mock|
    mock.get "/api/v2/accounts.json?email=#{URI.escape(email_address,"@")}", {"Authorization"=>"Basic cmF0YXRvc2s6dGVzdF9wYXNz",'Accept' => 'application/json'}, [].to_json, 200
  end
end