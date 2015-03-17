require "spec_helper"

describe ContactsController, type: 'controller' do

  # GET /contacts/meta_search                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET meta_search" do
    let(:contact1) { FactoryGirl.create(:contact, account: FactoryGirl.create(:account)) }
    let(:contact2) { FactoryGirl.create(:contact, account: FactoryGirl.create(:account)) }
    let(:res) { [contact1, contact2] }
    let(:results) { double(result: double(limit: res), limit: res) }
    let(:json_opts) { {only: [], methods: [:id, :name], include: {account: {only: [:id, :name]}, account_contact: {only: [:id, :account_id]}} } }
    let(:xml_opts) { json_opts }
    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/json"
      allow(controller).to receive(:require_application).and_return(true)
    end

    describe "with mime type" do
      before(:each) do
        expect(Contact).to receive(:search).with('id_eq' => '1').and_return(results)
      end
      it "JSON: should render JSON data" do
        get :meta_search, :search => {:id_eq => 1}
        expect(response.body).to eql([contact1, contact2].to_json(json_opts))
      end
      it "XML: should render XML data" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :meta_search, :search => {:id_eq => 1}
        expect(response.body).to eql([contact1, contact2].to_xml(xml_opts))
      end
    end

    describe "with text_search" do
      it "should call text_search on the contact class" do
        expect(Contact).to receive(:text_search).with('Jim').and_return(results)
        get :meta_search, :search => {:text_search => "Jim"}
      end
    end

    describe "with ransack" do

      it "should run an id_in search" do
        expect(Contact).to receive(:search).with('id_in' => ['1' ,'2']).and_return(results)
        get :meta_search, :search => {:id_in => ['1', '2']}, :only => [:id, :name]
        expect(response.body).to eql([contact1, contact2].to_json(json_opts))
      end

      it "should query ransack using custom fields" do
        expect(Contact).to receive(:search).with('cf_weibo' => '1234567890ABCDEF').and_return(results)
        get :meta_search, :search => {cf_weibo: '1234567890ABCDEF'}
      end

      it "should query ransack using multi-field search: " do
        search = {'alt_email_or_email_or_mobile_or_phone_cont' => contact1.phone}
        expect(Contact).to receive(:search).with(search).and_return(results)
        get :meta_search, search: search
      end

    end

    describe "usings params[:only]" do

      it "should return id, name and email when id is not specified" do
        expect(Contact).to receive(:search).with('id_in' => ['1', '2', '3']).and_return(results)
        get :meta_search, :search => {:id_in => [1,2,3]}, :only => [:name, :email]
        expect(response.body).to eql([contact1, contact2].to_json(only: [], methods: [:id, :name, :email], include: {account: {only: [:id, :name]}, account_contact: {only: [:id, :account_id]}}))
      end

      it "should return name, email, phone and account id and name" do
        expect(Contact).to receive(:search).with('id_eq' => '1').and_return(results)
        get :meta_search, search: {id_eq: "1"}, only: [:name, :email, :phone]
        resp = response.body
        expect(resp).to eql([contact1, contact2].to_json(only: [], methods: [:id, :name, :email, :phone], include: { account: { only: [:id, :name] }, account_contact: {only: [:id, :account_id]} }))
        expect(resp).to include(contact1.account.name)
        expect(resp).to include("#{contact1.account.id}")
        expect(resp).to include(contact2.account.name)
        expect(resp).to include("#{contact2.account.id}")
      end

    end

    it "should return no results with empty params" do
      get :meta_search
      expect(response.body).to eql([].to_json)
    end

  end

end
