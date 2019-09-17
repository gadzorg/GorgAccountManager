def authorization_header
  {
    "Authorization" =>
      ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.secrets.gram_api_user,
        Rails.application.secrets.gram_api_password,
      ),
  }
end
