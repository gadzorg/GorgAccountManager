require "rails_helper"

RSpec.describe AdminController, type: :controller do
  def login(user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  shared_examples_for "an admin only endpoint" do |destination, params = {}|
    context "user login as basic user" do
      before :each do
        login create(:user, firstname: "Ulysse", email: "Ulysse@hotmail.com")
        get destination, params: params
      end

      it { is_expected.to respond_with :forbidden }
    end

    context "user not login" do
      before :each do
        create(:user, firstname: "Ulysse", email: "Ulysse@hotmail.com")
        get destination, params: params
      end

      it { is_expected.to respond_with :redirect }
      it { is_expected.to redirect_to new_user_session_path }
    end
  end

  it_should_behave_like "an admin only endpoint", :index
  it_should_behave_like "an admin only endpoint", :stats
  it_should_behave_like "an admin only endpoint", :searches
  it_should_behave_like "an admin only endpoint", :search_user
  it_should_behave_like "an admin only endpoint", :recovery_sessions

  context "as logged admin" do
    before :each do
      login create(:user, :admin)
    end

    describe "GET #index" do
      context "user login as admin" do
        before(:each) { get :index }

        it { is_expected.to respond_with :success }
      end
    end

    describe "GET #stats" do
      context "user login as admin" do
        before(:each) { get :stats }

        it { is_expected.to respond_with :success }
      end
    end

    describe "GET #searches" do
      context "user login as admin" do
        before(:each) { get :searches }

        it { is_expected.to respond_with :success }
      end
    end

    describe "GET #search_user" do
      context "missing hruid" do
        before :each do
          get :search_user
        end

        it { is_expected.to respond_with :success }
      end

      context "unknown hruid" do
        let(:hruid) { "abc" }

        before :each do
          gam = GramAccountMocker.new
          gam.mock_search_request_for(:hruid, hruid, [])
          get :search_user, params: { hruid: hruid }
        end

        it { is_expected.to redirect_to admin_search_user_path }
      end

      context "search a real user" do
        let(:hruid) { "some.hruid.ext" }
        let(:uuid) { "9c5b8bd7-fce8-4790-b246-61b753c063e9" }

        before :each do
          gam = GramAccountMocker.for(uuid: uuid, hruid: hruid)
          gam.mock_search_request_for(:hruid, hruid)

          get :search_user, params: { hruid: hruid }
        end

        it { is_expected.to redirect_to admin_info_user_path(uuid: uuid) }
      end
    end

    describe "GET #recovery_sessions" do
      let!(:sessions) { create_list(:recoverysession, 2) }

      context "user login as admin" do
        before(:each) { get :recovery_sessions }

        it { is_expected.to respond_with :success }
      end
    end

    describe "POST #add_inscriptions" do
      let!(:soce_users) { create_list(:soce_user, 2) }

      context "user login as admin" do
        subject do
          post :add_inscriptions,
               params: { hruids: soce_users.map(&:hruid).join("\r\n") }
        end

        it { is_expected.to redirect_to admin_inscriptions_path }
        it { expect { subject }.to change(Uniqlink, :count).by(2) }
      end
    end
  end
end
