require "rails_helper"

RSpec.describe StaticPagesController, type: :controller do
  describe "GET #index" do
    before :each do
      get :index
    end
    it { is_expected.to respond_with :success }
  end
end
