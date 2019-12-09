
require 'rails_helper'

RSpec.describe RecoveryService, type: :service do

  let(:gam) {GramAccountMocker.new(uuid: "559bb0aa-ddac-4607-ad41-7e520ee40819")}
  before(:each) {gam.mock_get_request}

  subject {RecoveryService.new(build(:recoverysession, uuid: "559bb0aa-ddac-4607-ad41-7e520ee40819"))}

  describe "hidden_phone_number" do
    context "without phone number" do
      let! (:soce_user) {create(:soce_user, uuid: "559bb0aa-ddac-4607-ad41-7e520ee40819", tel_mobile: nil)}

      it "returns nil" do
        expect(subject.hidden_phone_number).to be_nil
      end

    end

    context "not parsable phone number" do
      let! (:soce_user) {create(:soce_user, uuid: "559bb0aa-ddac-4607-ad41-7e520ee40819", tel_mobile: '')}

      it "returns nil" do
        expect(subject.hidden_phone_number).to be_nil
      end
    end
  end
end
