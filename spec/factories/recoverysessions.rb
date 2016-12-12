FactoryGirl.define do
  factory :recoverysession do

    uuid {SecureRandom.uuid}
    expire_date { DateTime.now + Recoverysession::SESSION_TTL }
    token {SecureRandom.urlsafe_base64(nil, false)}

  end
end
