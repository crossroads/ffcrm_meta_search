require 'spec_helper'

describe ContactsController do

  # GET /contacts/meta_search                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET meta_search" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/json"
      @controller.stub(:require_application, true)
      @contact1 = FactoryGirl.create(:contact)
      @contact1.account = @account1 = FactoryGirl.create(:account)
      @contact1.account_contact = FactoryGirl.create(:account_contact, :account => @account1)
      @contact2 = FactoryGirl.create(:contact)
      @contact2.account = @account2 = FactoryGirl.create(:account)
      @contact2.account_contact = FactoryGirl.create(:account_contact, :account => @account2)
      @res = [@contact1, @contact2]
      @results = mock(:result => mock(:limit => @res), :limit => @res)
      @json_opts = @xml_opts = {:only => [], :methods => [:id, :name], :include => {:account => {:only => [:id, :name]}, :account_contact => {:only => [:id, :account_id]}} }
    end

    describe "with mime type" do
      before(:each) do
        Contact.should_receive(:search).with('id_eq' => '1').and_return(@results)
      end
      it "JSON: should render JSON data" do
        get :meta_search, :search => {:id_eq => 1}
        response.body.should == [ @contact1, @contact2 ].to_json(@json_opts)
      end
      it "XML: should render XML data" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :meta_search, :search => {:id_eq => 1}
        response.body.should == [ @contact1, @contact2 ].to_xml(@xml_opts)
      end
    end
    
    describe "with text_search" do
    
      it "should call text_search on the contact class" do
        Contact.should_receive(:text_search).with('Jim').and_return(@results)
        get :meta_search, :search => {:text_search => "Jim"}
      end
    
    end
    
    describe "with ransack" do
    
      it "should run an id_in search" do
        Contact.should_receive(:search).with('id_in' => ['1' ,'2']).and_return(@results)
        get :meta_search, :search => {:id_in => ['1', '2']}, :only => [:id, :name]
        response.body.should == [@contact1, @contact2].to_json(@json_opts)
      end
      
      it "should query ransack using custom fields" do
        Contact.should_receive(:search).with('cf_weibo' => '1234567890ABCDEF').and_return(@results)
        get :meta_search, :search => {:cf_weibo => '1234567890ABCDEF'}
      end
      
      it "should query ransack using multi-field search: " do
        search = {'alt_email_or_email_or_mobile_or_phone_cont' => @contact1.phone}
        Contact.should_receive(:search).with(search).and_return(@results)
        get :meta_search, :search => search
      end
      
    end
    
    describe "usings params[:only]" do
    
      it "should return id, name and email when id is not specified" do
        Contact.should_receive(:search).with('id_in' => ['1', '2', '3']).and_return(@results)
        get :meta_search, :search => {:id_in => [1,2,3]}, :only => [:name, :email]
        response.body.should == [ @contact1, @contact2 ].to_json(:only => [], :methods => [:id, :name, :email], :include => {:account => {:only => [:id, :name]}, :account_contact => {:only => [:id, :account_id]}})
      end
      
      it "should return name, email, phone and account id and name" do
        Contact.should_receive(:search).with('id_eq' => '1').and_return(@results)
        get :meta_search, :search => {:id_eq => '1'}, :only => [:name, :email, :phone]
        resp = response.body
        resp.should == [ @contact1, @contact2 ].to_json(:only => [], :methods => [:id, :name, :email, :phone], :include => { :account => { :only => [:id, :name] }, :account_contact => {:only => [:id, :account_id]} })
        resp.should include(@account1.name)
        resp.should include("#{@account1.id}")
        resp.should include(@account2.name)
        resp.should include("#{@account2.id}")
      end
    
    end
    
    it "should return no results with empty params" do
      get :meta_search
      response.body.should == [].to_json
    end

  end

end
