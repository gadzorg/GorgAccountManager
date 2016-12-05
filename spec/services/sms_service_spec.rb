require 'rails_helper'

RSpec.describe SmsService, type: :service do

  let(:phone_number) {"0623456789"}
  let(:phone_number_with_international_prefix) {"0033623456789"}

  subject {SmsService.new(phone_number)}

  describe 'initialize' do
    it "set recipient" do
      ss=SmsService.new(phone_number_with_international_prefix)
      expect(ss.recipient).to eq(phone_number_with_international_prefix)
    end

    describe "parses recipient to international format" do

      context "international format" do
        let(:phone_number) {"0033623456789"}
        it "parse " do
          expect(subject.recipient).to eq("0033623456789")
        end
      end

      context "parses french phone number" do
        let(:phone_number) {"0623456789"}
        it "parse "do
          expect(subject.recipient).to eq("0033623456789")
        end
      end

      context "parses soce-like phone number" do
        let(:phone_number) {"06.23.45.67.89"}
        it "parse " do
          expect(subject.recipient).to eq("0033623456789")
        end
      end

      context "parses e164 phone number" do
        let(:phone_number) {"+33623456789"}
        it "parse " do
          expect(subject.recipient).to eq("0033623456789")
        end
      end

      context "parses US phone number" do
        let(:phone_number) {"1-202-555-0188"}
        it "parse " do
          expect(subject.recipient).to eq("0012025550188")
        end
      end



    end

    it "set from" do
      ss=SmsService.new(phone_number, from: "toto")
      expect(ss.from).to eq("toto")
    end

    it "default from to secrets value" do
      ss=SmsService.new(phone_number)
      expect(ss.from).to eq(Rails.application.secrets.ovh_sms_from)
    end
  end

  describe "send_message" do

    let(:base_url) {"https://www.ovh.com/cgi-bin/sms/http2sms.cgi"}
    let(:from) {Rails.application.secrets.ovh_sms_from}
    let(:account) {Rails.application.secrets.ovh_sms_account}
    let(:login) {Rails.application.secrets.ovh_sms_login}
    let(:password) {Rails.application.secrets.ovh_sms_password}

    let(:successful_response) {{"status"=>100, "smsIds"=>["69265512"], "creditLeft"=>"230.50"}.to_json}
    let(:error_response) {{"status"=>201, "message"=>"Missing message. For more informations : http://guides.ovh.com/http2Sms"}.to_json}

    it "send a message" do
      stub_request(:get, /#{base_url}?.*/).to_return(:status => 200, :body => successful_response, :headers => {})
      subject.send_message("Salut ?")
      endoded_message="Salut%20?"
      expect(
          a_request(:get,  "#{base_url}?account=#{account}&contentType=text/json&from=#{from}&login=#{login}&message=#{endoded_message}&noStop=1&password=#{password}&to=#{phone_number_with_international_prefix}")
      ).to have_been_made.once
    end

    context "successful" do
      it "returns true" do
        stub_request(:get, /#{base_url}?.*/).to_return(:status => 200, :body => successful_response, :headers => {})
        expect(subject.send_message("Salut ?")).to be true
      end
    end

    context "error" do

      before(:each) do
        stub_request(:get, /#{base_url}?.*/).to_return(:status => 200, :body => error_response, :headers => {})
      end

      it "returns false" do
        expect(subject.send_message("Salut ?")).to be false
      end
      it "set errors " do
        subject.send_message("Salut ?")
        expect(subject.error).to eq("Missing message. For more informations : http://guides.ovh.com/http2Sms")
      end
    end

  end
end