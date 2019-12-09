# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

RSpec.describe Role, type: :model do
  it "has a valid factory" do
    expect(build(:role)).to be_valid
  end

  it "is invalid if name already exist" do
    create(:role, :distinct, name: "admin")
    expect(build(:role, :distinct, name: "admin")).not_to be_valid
  end
end
