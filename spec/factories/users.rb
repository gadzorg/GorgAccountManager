# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  hruid                  :string
#  firstname              :string
#  lastname               :string
#  role_id                :integer
#  last_gram_sync_at      :datetime
#

require "faker"

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    hruid do
      firstname.downcase.gsub(/[^a-z]/, "-") + "." +
        lastname.downcase.gsub(/[^a-z]/, "-") +
        "." +
        %w[1950 2015 ext soce associe].sample +
        ["", ".2", ".3"].sample
    end
    password { Devise.friendly_token[0, 20] }
    password_confirmation { password }
    uuid { SecureRandom.uuid }

    trait :admin do
      role { FactoryBot.create(:role, name: "admin") }
    end

    trait :support do
      role { FactoryBot.create(:role, name: "support") }
    end

    trait :invalid do
      email { nil }
    end
  end
end
