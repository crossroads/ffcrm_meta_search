require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "recognizes and generates #meta_search for" do

  it "accounts" do
    { :get => "/accounts/meta_search" }.should route_to(:controller => "accounts", :action => "meta_search")
  end

  it "campaigns" do
    { :get => "/campaigns/meta_search" }.should route_to(:controller => "campaigns", :action => "meta_search")
  end

  it "contacts" do
    { :get => "/contacts/meta_search" }.should route_to(:controller => "contacts", :action => "meta_search")
  end

  it "leads" do
    { :get => "/leads/meta_search" }.should route_to(:controller => "leads", :action => "meta_search")
  end

  it "opportunities" do
    { :get => "/opportunities/meta_search" }.should route_to(:controller => "opportunities", :action => "meta_search")
  end

  it "tasks" do
    { :get => "/tasks/meta_search" }.should route_to(:controller => "tasks", :action => "meta_search")
  end
end
