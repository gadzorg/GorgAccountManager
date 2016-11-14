require 'rails_helper'

RSpec.describe Role, type: :service do

  describe "password validation" do

    def accept(pass)
      ps=PasswordService.new(pass)
      expect(ps.validate).to be_truthy
      expect(ps.errors.count).to eq(0)
    end

    def reject(pass)
      ps=PasswordService.new(pass)
      expect(ps.validate).to be_falsy
      expect(ps.errors.count).to be > 0
    end


    it "validates a password" do
      accept("Un3 p@ssPhr4se")
    end
    it "accepts all character from google rules" do
      accept("123456789  ABCDEFGHIJKLMNOPQRSTUVWXYZ  abcdefghijklmnopqrstuvwxyz! \" # $ % & ‘ ( ) * + , - . / : ; < = > ? @ [ \ ] ^ { | } ~")
    end
    it "reject empty passwords" do
      reject("")
    end
    it "reject 7 char passwords" do
      reject("1234567")
    end
    it "reject password starting with space" do
      reject(" 12345678")
    end
    it "reject password ending with space" do
      reject("12345678 ")
    end
    it "reject password containing new lines with space" do
      reject("1234\n5678")
    end
    it "reject special characters" do
      reject("12345678é")
    end

  end

end