require "rails_helper"

RSpec.describe "/opportunities/meta_search", type: :request do

  # GET /opportunities/meta_search                                         AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET meta_search" do
    let(:account) { FactoryBot.create(:account) }
    let(:api_key) { "akeo430gkfk3-d-pdkskkkds" }

    before(:each) do
      Setting.ffcrm_meta_search = { 'api_key' => api_key }
    end

    describe "with mime type of JSON" do
      it "should perform meta search using params" do
        won = FactoryBot.create(:opportunity, account: account, stage: 'won')
        get "/opportunities/meta_search", params: { search: {stage_eq: "won"}, api_key: api_key }, headers: { "ACCEPT" => "application/json" }
        expect(response.body).to eql([ won ].to_json(only: [], methods: [:id, :name]))
      end
    end

    describe "with mime type of XML" do
      it "should perform meta search using params and render XML" do
        lost = FactoryBot.create(:opportunity, account: account, stage: 'lost')
        get "/opportunities/meta_search", params: { search: {stage_eq: "lost"}, api_key: api_key }, headers: { "ACCEPT" => "application/xml" }
        expect(response.body).to eql([lost].to_xml(only: [], methods: [:id, :name]))
      end
    end

    describe "with bad api_key" do
      it "should return error message" do
        get "/opportunities/meta_search", params: { search: {stage_eq: "lost"}, api_key: 'bad' }, headers: { "ACCEPT" => "application/xml" }
        expect(response.body).to include("Please specify a valid api_key in the meta_search url.")
      end
    end

  end
end
