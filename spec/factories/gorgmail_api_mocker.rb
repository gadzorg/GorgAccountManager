require 'webmock'
include WebMock::API

class GorgmailApiMocker

  def initialize

    #stub_request(:get, /https:\/\/www.ovh.com\/cgi-bin\/sms\/http2sms.cgi.*/).to_return(:status => 200, :body => {"status"=>100, "smsIds"=>["69265512"], "creditLeft"=>"230.50"}.to_json, :headers => {})
  end

  def url(path_array)
    URI::join(Rails.application.secrets.gorgmail_api_url, *path_array)
  end

  def mock_search_query(request,result)
    if result
      response={
          :status => 200,
          :body => {uuid: result}.to_json,
          :headers => {}
      }
    else
      response={
          :status => 404,
          :body => {error:{status: 404, message: "Email not found"}}.to_json,
          :headers => {}
      }
    end
    WebMock.stub_request(:get, url(["search/", request])).to_return(response)
  end

  def mock_unavailable_search_query(request)
    WebMock.stub_request(:get, url(["search/", request])).to_timeout
  end

end