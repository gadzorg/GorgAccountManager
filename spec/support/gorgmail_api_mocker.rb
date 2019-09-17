require "webmock"

class GorgmailApiMocker
  def url(path_array)
    URI.join(Rails.application.secrets.gorgmail_api_url, *path_array)
  end

  def mock_search_query(request, result)
    response =
      if result
        { status: 200, body: { uuid: result }.to_json, headers: {} }
      else
        {
          status: 404,
          body: { error: { status: 404, message: "Email not found" } }.to_json,
          headers: {},
        }
      end

    WebMock.stub_request(:get, url(["search/", request])).to_return(response)
  end

  def mock_unavailable_search_query(request)
    WebMock.stub_request(:get, url(["search/", request])).to_timeout
  end
end
