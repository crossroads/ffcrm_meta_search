require "rails_helper"

RSpec.describe "/contacts/meta_search", type: :request do

  # GET /contacts/meta_search                                              AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET meta_search" do
    let(:contact1) { FactoryBot.create(:contact, account: FactoryBot.create(:account)) }
    let(:contact2) { FactoryBot.create(:contact, account: FactoryBot.create(:account)) }
    let(:api_key) { "akeo430gkfk3-d-pdkskkkds" }

    before(:each) do
      Setting.ffcrm_meta_search = { 'api_key' => api_key }
    end

    describe "with mime type" do
      it "JSON" do
        get "/contacts/meta_search", params: { search: {id_eq: contact1.id}, api_key: api_key}, headers: { "ACCEPT" => "application/json" }
        json_body = JSON.parse(response.body).first
        expect(json_body["name"]).to eql(contact1.name)
        expect(json_body["account"]["name"]).to eql(contact1.account.name)
        expect(json_body["account_contact"]["account_id"]).to eql(contact1.account_contact.account_id)
      end
      it "XML" do
        get "/contacts/meta_search", params: { search: {id_eq: contact1.id}, api_key: api_key}, headers: { "ACCEPT" => "application/xml" }
        expect(response.body).to include(contact1.name)
        expect(response.body).to_not include(contact2.name)
      end
    end

    describe "with text_search" do
      it "with text_search" do
        get "/contacts/meta_search", params: { search: {text_search: contact1.name}, api_key: api_key}, headers: { "ACCEPT" => "application/json"}
        json_body = JSON.parse(response.body).first
        expect(json_body["name"]).to eql(contact1.name)
      end
    end

    describe "with ransack" do

      it "id_in" do
        get "/contacts/meta_search", params: { search: {id_in: [contact1.id, contact2.id]}, api_key: api_key}, headers: { "ACCEPT" => "application/json" }
        json_body = JSON.parse(response.body)
        expect( json_body.map{|x| x['id']} ).to match_array([contact1.id, contact2.id])
        expect( json_body.map{|x| x['name']} ).to match_array([contact1.name, contact2.name])
      end

      it "custom field search" do
        field_group = FieldGroup.where(klass_name: "Contact", name: 'custom_fields').first
        field_group ||= FieldGroup.create(name: 'custom_fields', label: 'Custom Fields', klass_name: 'Contact')
        CustomField.create(as: 'string', name: 'cf_weibo', label: "Weibo", field_group: field_group)
        contact1 = FactoryBot.create(:contact, cf_weibo: "1234567890ABCDEF")
        get "/contacts/meta_search", params: { search: {cf_weibo: '1234567890ABCDEF'}, api_key: api_key}, headers: { "ACCEPT" => "application/json"}
        json_body = JSON.parse(response.body).first
        expect( json_body['id'] ).to eql(contact1.id)
        expect( json_body['name'] ).to eql(contact1.name)
      end

      it "multi-field search" do
        get "/contacts/meta_search", params: { search: {'alt_email_or_email_or_mobile_or_phone_cont' => contact1.phone}, api_key: api_key}, headers: { "ACCEPT" => "application/json"}
        json_body = JSON.parse(response.body).first
        expect( json_body['id'] ).to eql(contact1.id)
        expect( json_body['name'] ).to eql(contact1.name)
      end

    end

    describe "usings params[:only]" do

      it "should return id, name and email when id is not specified" do
        get "/contacts/meta_search", params: { search: {id_in: [contact1.id]}, only: [:name, :email], api_key: api_key}, headers: { "ACCEPT" => "application/json"}
        json_body = JSON.parse(response.body).first
        expect(json_body["name"]).to eql(contact1.name)
        expect(json_body["email"]).to eql(contact1.email)
        expect(json_body.keys).to_not include("phone")
      end

      it "should return name, email, phone and account id and name" do
        get "/contacts/meta_search", params: { search: {id_in: [contact1.id]}, only: [:name, :email, :phone], api_key: api_key}, headers: { "ACCEPT" => "application/json"}
        json_body = JSON.parse(response.body).first
        expect(json_body["name"]).to eql(contact1.name)
        expect(json_body["email"]).to eql(contact1.email)
        expect(json_body["phone"]).to eql(contact1.phone)
      end

    end

    it "should return no results with empty params" do
      get "/contacts/meta_search", params: { api_key: api_key }, headers: { "ACCEPT" => "application/json"}
      expect(response.body).to eql([].to_json)
    end

  end

end
