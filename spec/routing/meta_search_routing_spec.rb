require 'rails_helper'

describe "recognizes and generates #meta_search for", type: 'routing' do
  it "accounts" do
    expect(get: "/accounts/meta_search").to route_to(controller: "accounts", action: "meta_search")
  end

  it "campaigns" do
    expect(get: "/campaigns/meta_search").to route_to(controller: "campaigns", action: "meta_search")
  end

  it "contacts" do
    expect(get: "/contacts/meta_search").to route_to(controller: "contacts", action: "meta_search")
  end

  it "leads" do
    expect(get: "/leads/meta_search").to route_to(controller: "leads", action: "meta_search")
  end

  it "opportunities" do
    expect(get: "/opportunities/meta_search").to route_to(controller: "opportunities", action: "meta_search")
  end

  it "tasks" do
    expect(get: "/tasks/meta_search").to route_to(controller: "tasks", action: "meta_search")
  end
end
