require 'spec_helper'

describe ContactsController do

  # GET /contacts/meta_search                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET meta_search" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/json"
      @controller.stub(:require_application, true)
      @contact1 = FactoryGirl.create(:contact)
      @contact2 = FactoryGirl.create(:contact)
      @res = mock(:all => [@contact1, @contact2])
      @results = mock(:result => @res)
    end

    describe "with mime type" do
      before(:each) do
        Contact.should_receive(:search).with('id_eq' => '1').and_return(@results)
      end
      it "JSON: should render JSON data" do
        get :meta_search, :search => {:id_eq => 1}
        response.body.should == [ @contact1, @contact2 ].to_json(:only => [:id], :methods => [:name])
      end
      it "XML: should render XML data" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :meta_search, :search => {:id_eq => 1}
        response.body.should == [ @contact1, @contact2 ].to_xml(:only => [:id], :methods => [:name])
      end
    end
    
    describe "with text_search" do
    
      it "should call text_search on the contact class" do
        res = mock()
        res.should_receive(:all).with(:limit => 10).and_return([@contact1, @contact2])
        Contact.should_receive(:text_search).with('Jim').and_return(res)
        get :meta_search, :search => {:text_search => "Jim"}
      end
    
    end
    
    #
    # Tests are a bit redundant but they give good documentation for what you can do
    #
    describe "with ransack" do
    
      it "should run an id_in search" do
        Contact.should_receive(:search).with('id_in' => ['1', '2', '3']).and_return(@results)
        get :meta_search, :search => {:id_in => [1,2,3]}
      end
      
      it "should query ransack using custom fields" do
        Contact.should_receive(:search).with('cf_weibo' => '1234567890ABCDEF').and_return(@results)
        get :meta_search, :search => {:cf_weibo => '1234567890ABCDEF'}
      end
      
      it "should query ransack using multi-field search" do
        Contact.should_receive(:search).with('alt_email_or_email_or_mobile_or_phone_cont' => '1234').and_return(@results)
        get :meta_search, :search => {:alt_email_or_email_or_mobile_or_phone_cont => '1234'}
      end
      
    end
    
    describe "usings params[:only]" do
    
      it "should return id, name and email when id is not specified" do
        Contact.should_receive(:search).with('id_in' => ['1', '2', '3']).and_return(@results)
        get :meta_search, :search => {:id_in => [1,2,3]}, :only => [:name, :email]
        response.body.should == [ @contact1, @contact2 ].to_json(:only => [], :methods => [:id, :name, :email])
      end
      
      it "should return name, email, phone and account id and name" do
        account = FactoryGirl.create(:account)
        @contact1.account = account
        Contact.should_receive(:search).with('id_eq' => '1').and_return(@results)
        get :meta_search, :search => {:id_eq => '1'}, :only => [:name, :email, :phone]
        resp = response.body
        resp.should == [ @contact1, @contact2 ].to_json(:only => [], :methods => [:id, :name, :email, :phone], :include => { :account => { :only => [:id, :name] } })
        resp.should include(account.name)
        resp.should include("#{account.id}")
      end
    
    end
    
    it "should return no results with empty params" do
      get :meta_search
      response.body.should == [].to_json
    end
        
  end
  
  describe "replace_aliases" do
  
  end
  
  describe "factor_aliases" do
  
  end
  
end
