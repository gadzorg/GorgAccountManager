require 'rails_helper'

describe "routing to products" , :type => :routing do
  it "routes /users/123456 to products#show" do
    expect(get: "/users/123456").to route_to(
                                    controller: "users",
                                    action: "show",
                                    id: "123456"
                                )
  end

  it "routes /users/alexandre.narbonne to products#show" do
    expect(get: "/users/alexandre.narbonne.2011").to route_to(
                                        controller: "users",
                                        action: "show",
                                        id: "alexandre.narbonne.2011"
                                    )
  end

  it "routes /users/ffd7c8c6-3082-4f4a-b8de-0d30744d4e2d to products#show" do
    expect(get: "/users/ffd7c8c6-3082-4f4a-b8de-0d30744d4e2d").to route_to(
                                        controller: "users",
                                        action: "show",
                                        id: "ffd7c8c6-3082-4f4a-b8de-0d30744d4e2d"
                                    )
  end

  it "routes /users/autocomplete_user_hruid to products#autocomplete_user_hruid" do
    expect(get: "/users/autocomplete_user_hruid").to route_to(
                                        controller: "users",
                                        action: "autocomplete_user_hruid"
                                    )
  end

end