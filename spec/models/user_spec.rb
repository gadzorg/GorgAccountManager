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

require 'rails_helper'


RSpec.describe User, type: :model do
  
  it "has a valid factory" do
    expect(FactoryGirl.build(:user)).to be_valid
  end


end
