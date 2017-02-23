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

  describe 'find by id or hruid' do
    let!(:user) {FactoryGirl.create(:user)}

    it "find by id" do
      expect(User.find_by_id_or_hruid_or_uuid(user.id)).to eq(user)
    end

    it "find by uuid" do
      expect(User.find_by_id_or_hruid_or_uuid(user.uuid)).to eq(user)
    end

    it "find by hruid" do
      expect(User.find_by_id_or_hruid_or_uuid(user.hruid)).to eq(user)
    end
  end

  describe "search" do

    let!(:alice) {FactoryGirl.create(:user, firstname: 'Alice', hruid:'alice.alabama.2000', email:'alice@hotmail.com')}
    let!(:bob) {FactoryGirl.create(:user, firstname: 'Bob', hruid:'bob.beacon.2001', email:'bob@hotmail.com')}
    let!(:charlie) {FactoryGirl.create(:user, firstname: 'Charlie', hruid:'charlie.chaplin.2001', email:'charlie@hotmail.com')}

    it "returns all on nil query" do
      expect(User.search(nil)).to match_array([alice,bob,charlie])
    end


    it "find one" do
      expect(User.search("alice.alabama")).to match_array([alice])
    end

    it "is case incensitive" do
      expect(User.search("Alice.AlAbAmA")).to match_array([alice])
    end

    it "find many" do
      expect(User.search("2001")).to match_array([bob,charlie])
    end
  end

end
