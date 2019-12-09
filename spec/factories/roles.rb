# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :role do
    name { "admin" }
    initialize_with { Role.find_or_create_by name: name }

    trait :distinct do
      initialize_with { Role.new }
    end

    trait :invalid do
      name { nil }
      initialize_with { Role.new }
    end
  end
end
