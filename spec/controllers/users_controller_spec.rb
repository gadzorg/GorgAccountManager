require "rails_helper"

RSpec.describe UsersController, type: :controller do
  def login(user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  shared_examples_for "an admin only endpoint" do |destination|
    let! (:params) do
      {}
    end
    context "user login as target user" do
      before :each do
        @user ||=
          create(:user, firstname: "Ulysse", email: "Ulysse@hotmail.com")
        login @user
        get destination, params: params
      end

      it { is_expected.to respond_with :forbidden }
    end

    context "user login as other user" do
      before :each do
        @user2 = create(:user, firstname: "Didier", email: "Didier@hotmail.com")
        login @user2
        get destination, params: params
      end

      it { is_expected.to respond_with :forbidden }
    end

    context "user not login" do
      before :each do
        @user = create(:user, firstname: "Ulysse", email: "Ulysse@hotmail.com")
        get destination, params: params
      end

      it { is_expected.to respond_with :redirect }
      it { is_expected.to redirect_to new_user_session_path }
    end
  end

  shared_examples_for "an target user or admin only endpoint" do |destination|
    let! (:params) do
      {}
    end
    context "user login as target user" do
      before :each do
        @user ||=
          create(:user, firstname: "Ulysse", email: "Ulysse@hotmail.com")
        login @user
        get destination, params: params
      end

      it { is_expected.to respond_with :success }
    end

    context "user login as other user" do
      before :each do
        @user2 = create(:user, firstname: "Didier", email: "Didier@hotmail.com")
        login @user2
        get destination, params: params
      end

      it { is_expected.to respond_with :forbidden }
    end

    context "user not login" do
      before :each do
        @user = create(:user, firstname: "Ulysse", email: "Ulysse@hotmail.com")
        get destination, params: params
      end

      it { is_expected.to respond_with :redirect }
      it { is_expected.to redirect_to new_user_session_path }
    end
  end

  describe "GET #index" do
    before :each do
      @alice =
        create(
          :user,
          firstname: "Alice",
          hruid: "alice.alabama.2000",
          email: "alice@hotmail.com",
        )
      @bob =
        create(
          :user,
          firstname: "Bob", hruid: "bob.beacon.2001", email: "bob@hotmail.com",
        )
      @charlie =
        create(
          :user,
          firstname: "Charlie",
          hruid: "charlie.chaplin.2001",
          email: "charlie@hotmail.com",
        )
    end

    it_should_behave_like "an admin only endpoint", :index

    context "user login as admin" do
      before :each do
        @admin =
          create(:user, :admin, firstname: "Admin", email: "admin@hotmail.com")
        login @admin
      end

      context "no query" do
        before(:each) { get :index }

        it { is_expected.to respond_with :success }
        it { is_expected.to render_with_layout "gorg_engine/application" }
        it { is_expected.to render_template :index }
        it "populate @users list with all users" do
          expect(assigns(:users)).to match_array(
            [@alice, @bob, @charlie, @admin],
          )
        end
      end

      describe "search" do
        before :each do
          get :index, params: { query: query }
        end

        context "multiple results" do
          let(:query) { "2001" }

          it { is_expected.to respond_with :success }
          it { is_expected.to render_with_layout "gorg_engine/application" }
          it { is_expected.to render_template :index }
          it "populate @users list with results" do
            expect(assigns(:users)).to match_array([@bob, @charlie])
          end
        end

        context "one result" do
          let(:query) { "alabama.2000" }

          it { is_expected.to respond_with :redirect }
          it { is_expected.to redirect_to user_path(@alice.id) }
        end
      end
    end
  end

  describe "GET #show" do
    before :each do
      @user = create(:user)
    end

    it_should_behave_like "an target user or admin only endpoint", :show do
      let! (:params) do
        { id: @user.id }
      end
    end

    context "user login as admin" do
      context "using user id" do
        let (:id) do
          @user.id
        end

        before :each do
          @admin =
            create(
              :user,
              :admin,
              firstname: "Admin", email: "admin@hotmail.com",
            )
          login @admin
          get :show, params: { id: id }
        end

        it { is_expected.to respond_with :success }
        it { is_expected.to render_with_layout "gorg_engine/application" }
        it { is_expected.to render_template :show }
        it "populate @user list with requested user" do
          expect(assigns(:user)).to eq(@user)
        end
      end

      context "using user uuid" do
        let (:id) do
          @user.uuid
        end

        before :each do
          @admin =
            create(
              :user,
              :admin,
              firstname: "Admin", email: "admin@hotmail.com",
            )
          login @admin
          get :show, params: { id: id }
        end

        it { is_expected.to respond_with :success }
        it { is_expected.to render_with_layout "gorg_engine/application" }
        it { is_expected.to render_template :show }
        it "populate @user list with requested user" do
          expect(assigns(:user)).to eq(@user)
        end
      end

      context "using user hruid" do
        let (:id) do
          @user.hruid
        end

        before :each do
          @admin =
            create(
              :user,
              :admin,
              firstname: "Admin", email: "admin@hotmail.com",
            )
          login @admin
          get :show, params: { id: id }
        end

        it { is_expected.to respond_with :success }
        it { is_expected.to render_with_layout "gorg_engine/application" }
        it { is_expected.to render_template :show }
        it "populate @user list with requested user" do
          expect(assigns(:user)).to eq(@user)
        end
      end
    end
  end

  describe "GET #new" do
    it_should_behave_like "an admin only endpoint", :new

    context "user login as admin" do
      before :each do
        @admin =
          create(:user, :admin, firstname: "Admin", email: "admin@hotmail.com")
        login @admin
        get :new
      end

      it { is_expected.to respond_with :success }
      it { is_expected.to render_with_layout "gorg_engine/application" }
      it { is_expected.to render_template :new }
      it "populate @user list new user" do
        expect(assigns(:user)).to be_a_new(User)
      end
    end
  end

  describe "GET #create" do
    it_should_behave_like "an admin only endpoint", :new

    context "user login as admin" do
      before :each do
        @admin =
          create(:user, :admin, firstname: "Admin", email: "admin@hotmail.com")
        login @admin
      end

      context "With valid data" do
        it do
          expect {
            post :create, params: { user: attributes_for(:user) }
          }.to change { User.count }.by(1)
        end
        it "respond with 302" do
          post :create, params: { user: attributes_for(:user) }
          is_expected.to respond_with :redirect
        end
        it "Redirect to create user #show" do
          post :create, params: { user: attributes_for(:user) }
          is_expected.to redirect_to user_path(assigns(:user).id)
        end
      end

      context "With invalid data" do
        it do
          expect {
            post :create, params: { user: attributes_for(:user, :invalid) }
          }.to_not change { User.count }
        end
        it "respond with 422" do
          post :create, params: { user: attributes_for(:user, :invalid) }
          is_expected.to respond_with :unprocessable_entity
        end
        it "Redirect to create user #show" do
          post :create, params: { user: attributes_for(:user, :invalid) }
          is_expected.to render_template :new
        end
      end
    end
  end

  describe "GET #edit" do
    before :each do
      @user = create(:user)
    end

    it_should_behave_like "an admin only endpoint", :edit do
      let! (:params) do
        { id: @user.id }
      end
    end

    context "user login as admin" do
      before :each do
        @admin =
          create(:user, :admin, firstname: "Admin", email: "admin@hotmail.com")
        login @admin
        get :edit, params: { id: @user.id }
      end

      it { is_expected.to respond_with :success }
      it { is_expected.to render_with_layout "gorg_engine/application" }
      it { is_expected.to render_template :edit }
      it "populate @user list expected user" do
        expect(assigns(:user)).to eq(@user)
      end
    end
  end

  describe "PUT #update" do
    before :each do
      @user = create(:user, firstname: "Bob", email: "bob@hotmail.com")
    end

    it_should_behave_like "an admin only endpoint", :update do
      let! (:params) do
        { id: @user.id }
      end
    end

    context "user login as admin" do
      before :each do
        @admin =
          create(:user, :admin, firstname: "Admin", email: "admin@hotmail.com")
        login @admin
      end

      context "With valid data" do
        before :each do
          put :update,
              params: {
                id: @user.id, user: attributes_for(:user, firstname: "Bobby")
              }
        end
        it "update user data" do
          expect(User.find(@user.id).firstname).to eq("Bobby")
        end
        it "populate @user list expected user" do
          expect(assigns(:user)).to eq(@user)
        end
        it { is_expected.to respond_with :redirect }
        it { is_expected.to redirect_to user_path(@user.id) }
      end

      context "With invalid data" do
        before :each do
          put :update,
              params: {
                id: @user.id,
                user: attributes_for(:user, firstname: "Bobby", email: ""),
              }
        end

        it "doesn't update user data" do
          expect(User.find(@user.id).email).to_not eq("")
          expect(User.find(@user.id).email).to eq("bob@hotmail.com")
        end
        it "respond with 422" do
          post :create, params: { user: attributes_for(:user, :invalid) }
          is_expected.to respond_with :unprocessable_entity
        end
        it "Redirect to create user #show" do
          post :create, params: { user: attributes_for(:user, :invalid) }
          is_expected.to render_template :new
        end
      end
    end
  end

  describe "GET #destroy" do
    before :each do
      @user = create(:user)
    end

    it_should_behave_like "an admin only endpoint", :destroy do
      let! (:params) do
        { id: @user.id }
      end
    end

    context "user login as admin" do
      before :each do
        @admin =
          create(:user, :admin, firstname: "Admin", email: "admin@hotmail.com")
        login @admin
      end

      it "deletes the contact" do
        expect { delete :destroy, params: { id: @user.id } }.to change(
          User,
          :count,
        )
          .by(-1)
      end

      it "respond with 302" do
        delete :destroy, params: { id: @user.id }
        is_expected.to respond_with :redirect
      end
      it "Redirect to create user #show" do
        delete :destroy, params: { id: @user.id }
        is_expected.to redirect_to users_path
      end
    end
  end
end
