require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpportunitiesController do
  before(:each) do
    require_user
  end

  # GET /opportunities/meta_search                                         AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET meta_search" do
    before(:each) do
      @account = Factory(:account)
      @won  = Factory(:opportunity, :account => @account, :stage => 'won')
      @lost = Factory(:opportunity, :account => @account, :stage => 'lost')
    end

    describe "with mime type of JSON" do
      it "should perform meta search using params" do
        request.env["HTTP_ACCEPT"] = "application/json"
        get :meta_search, :search => {:stage_eq => "won"}
        response.body.should == [ @won ].to_json(:only => [:id, :name])
      end
    end

    describe "with mime type of XML" do
      it "should perform meta search using params and render XML" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :meta_search, :search => {:stage_eq => "lost"}
        response.body.should == [ @lost ].to_xml(:only => [:id, :name])
      end
    end
  end
end
