
Around('@ovh') do |_scenario, block|
  @ovh_request=stub_request(:get, /https:\/\/www.ovh.com\/cgi-bin\/sms\/http2sms.cgi.*/).to_return(:status => 200, :body => "", :headers => {})
  block.call
end
