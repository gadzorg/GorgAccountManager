require 'rails_helper'


RSpec.describe  GramAccountSearcher, type: :service do

  let(:query) {"test.query"}
  fake(:search_logger)

  subject(:gas){GramAccountSearcher.new(query)}

  before(:each) do
    gam=GramAccountMocker.new
    gam.mock_search_request_for(:email,query,[])
    gam.mock_search_request_for(:hruid,query,[])
    gam.mock_search_request_for(:id_soce,"",[])
  end

  describe "initializer" do
    it "initialize its query" do
      expect(gas.query).to eq(query)
    end

    it "initialize its search_logger" do
      gas=GramAccountSearcher.new(query, search_logger: search_logger)
      expect(gas.search_logger).to eq(search_logger)
    end
  end

  describe "raise an error on empty queries" do
    it "nil query" do
      gas.query=nil
      expect{gas.perform}.to raise_error(GramAccountSearcher::BlankQuery)
    end

    it "nil query" do
      gas.query=""
      expect{gas.perform}.to raise_error(GramAccountSearcher::BlankQuery)
    end

  end

  it "is not automaticaly performed" do
    expect(gas.performed?).to be false
  end

  it "has not a search logger by default" do
    expect(gas.search_logger).to be_nil
  end

  describe "perform" do

    it "update its performed? status" do
      gas.perform
      expect(gas.performed?).to be true
    end

    it "log the search" do
      gas=GramAccountSearcher.new(query, search_logger: search_logger)
      gas.perform
      expect(search_logger).to have_received.log(query,"Non trouvé")
    end
  end

  context "not found" do
    it "return a nil uuid" do
      expect(gas.uuid).to be_nil
    end

    it "return a nil gram_account" do
      expect(gas.gram_account).to be_nil
    end
  end

  describe "perform when return value" do

    it "when request uuid" do
      gas.uuid
      expect(gas.performed?).to be true
    end

    it "when request gram_account" do
      gas.gram_account
      expect(gas.performed?).to be true
    end

  end

  describe "search attributes" do
    shared_examples_for "return values" do |uuid|
      it "returns the uuid" do
        expect(gas.uuid).to eq(uuid)
      end

      it "returns the gram account" do
        expect(gas.gram_account).to be_a(GramV2Client::Account)
        expect(gas.gram_account.uuid).to eq(uuid)
      end
    end

    context "search email" do
      let(:query) {"some.adress@example.com"}
      before(:each) do
        gam=GramAccountMocker.for(uuid: "9c5b8bd7-fce8-4790-b246-61b753c063e9",email: query)
        gam.mock_search_request_for(:email,query)
        gam.mock_search_request_for(:hruid,query,[])
        gam.mock_search_request_for(:id_soce,"",[])
        GorgmailApiMocker.new.mock_search_query(query,nil)
      end
      include_examples "return values", "9c5b8bd7-fce8-4790-b246-61b753c063e9"
    end

    context "search hruid" do
      let(:query) {"some.hruid.ext"}
      before(:each) do
        gam=GramAccountMocker.for(uuid: "9c5b8bd7-fce8-4790-b246-61b753c063e9",hruid: query)
        gam.mock_search_request_for(:email,query,[])
        gam.mock_search_request_for(:hruid,query)
        gam.mock_search_request_for(:id_soce,"",[])
        GorgmailApiMocker.new.mock_search_query(query,nil)
      end
      include_examples "return values", "9c5b8bd7-fce8-4790-b246-61b753c063e9"
    end

    context "search id_soce" do
      let(:query) {"123456A"}
      before(:each) do
        gam=GramAccountMocker.for(uuid: "9c5b8bd7-fce8-4790-b246-61b753c063e9",id_soce: 123456)
        gam.mock_search_request_for(:email,query,[])
        gam.mock_search_request_for(:hruid,query,[])
        gam.mock_search_request_for(:id_soce,123456)
        GorgmailApiMocker.new.mock_search_query(query,nil)
      end
      include_examples "return values", "9c5b8bd7-fce8-4790-b246-61b753c063e9"
    end


    context "search gorgmail mail address" do
      let(:query) {"some.adress@gorgmail.com"}
      before(:each) do
        gam=GramAccountMocker.for(uuid: "9c5b8bd7-fce8-4790-b246-61b753c063e9",id_soce: 123456)
        gam.mock_get_request
        gam.mock_search_request_for(:email,query,[])
        gam.mock_search_request_for(:hruid,query,[])
        gam.mock_search_request_for(:id_soce,"",[])
        GorgmailApiMocker.new.mock_search_query(query,"9c5b8bd7-fce8-4790-b246-61b753c063e9")
      end
      include_examples "return values", "9c5b8bd7-fce8-4790-b246-61b753c063e9"

      it 'handle unavailable API' do
        GorgmailApiMocker.new.mock_unavailable_search_query(query)
        expect(gas.uuid).to be_nil
      end
    end
  end

end