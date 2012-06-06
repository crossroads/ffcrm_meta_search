require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpportunitiesController do

  # GET /opportunities/meta_search                                         AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET meta_search" do
    before(:each) do
      @account = FactoryGirl.create(:account)
      @won  = FactoryGirl.create(:opportunity, :account => @account, :stage => 'won')
      @lost = FactoryGirl.create(:opportunity, :account => @account, :stage => 'lost')
      @controller.stub(:require_application, true)
    end

    describe "with mime type of JSON" do
      it "should perform meta search using params" do
        request.env["HTTP_ACCEPT"] = "application/json"
        get :meta_search, :search => {:stage_eq => "won"}
        response.body.should == [ @won ].to_json(:only => [], :methods => [:id, :name])
      end
    end

    describe "with mime type of XML" do
      it "should perform meta search using params and render XML" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :meta_search, :search => {:stage_eq => "lost"}       
        # Uses :methods => :name, in case name is aliased to return #id - #name
        response.body.should == [ @lost ].to_xml(:only => [], :methods => [:id, :name])
      end
    end
  end
end
