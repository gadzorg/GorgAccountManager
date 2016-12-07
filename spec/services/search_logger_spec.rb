require 'rails_helper'

RSpec.describe SearchLogger, type: :service do

  let(:query) {"Some query"}
  let(:type) {"Some type"}

  it "log a search" do
    expect{subject.log(query,type)}.to change(Search,:count).by(1)
  end

end