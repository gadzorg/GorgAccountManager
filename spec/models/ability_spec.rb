

require 'rails_helper'

RSpec.describe Ability, type: :model do


  describe "masquerade" do

    let(:ability) {Ability.new(current_user)}

    let(:user) {FactoryBot.create(:user)}
    let!(:admin) {FactoryBot.create(:admin)}
    let!(:support) {FactoryBot.create(:support)}


    context "as an admin" do
      let(:current_user) {FactoryBot.create(:admin)}

      it "can masquerade users" do
        expect(ability.can?(:masquerade,user)).to be true
      end
      it "cannot masquerade support user" do
        expect(ability.can?(:masquerade,support)).to be false
      end
      it "cannot masquerade an admin" do
        expect(ability.can?(:masquerade,admin)).to be false
      end

    end

    context "as a support admin" do
      let(:current_user) {FactoryBot.create(:support)}

      it "can masquerade users" do
        expect(ability.can?(:masquerade,user)).to be true
      end
      it "cannot masquerade support user" do
        expect(ability.can?(:masquerade,support)).to be false
      end
      it "cannot masquerade an admin" do
        expect(ability.can?(:masquerade,admin)).to be false
      end

    end

    context "as an user" do
      let(:current_user) {FactoryBot.create(:user)}

      it "cannot masquerade users" do
        expect(ability.can?(:masquerade,user)).to be false
      end
      it "cannot masquerade support user" do
        expect(ability.can?(:masquerade,support)).to be false
      end
      it "cannot masquerade an admin" do
        expect(ability.can?(:masquerade,admin)).to be false
      end

    end

  end


end
