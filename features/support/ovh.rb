
Around('@ovh') do |_scenario, block|
  @ovh_request=stub_request(:get, /https:\/\/www.ovh.com\/cgi-bin\/sms\/http2sms.cgi.*/).to_return(:status => 200, :body => {"status"=>100, "smsIds"=>["69265512"], "creditLeft"=>"230.50"}.to_json, :headers => {})
  block.call
end
