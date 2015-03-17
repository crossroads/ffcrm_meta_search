require "spec_helper"

describe OpportunitiesController, type: 'controller' do

  # GET /opportunities/meta_search                                         AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET meta_search" do
    let(:account) { FactoryGirl.create(:account) }
    before(:each) do
      allow(controller).to receive(:require_application).and_return(true)
    end

    describe "with mime type of JSON" do
      it "should perform meta search using params" do
        won = FactoryGirl.create(:opportunity, account: account, stage: 'won')
        request.env["HTTP_ACCEPT"] = "application/json"
        get :meta_search, :search => {:stage_eq => "won"}
        expect(response.body).to eql([ won ].to_json(only: [], methods: [:id, :name]))
      end
    end

    describe "with mime type of XML" do
      it "should perform meta search using params and render XML" do
        lost = FactoryGirl.create(:opportunity, account: account, stage: 'lost')
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :meta_search, :search => {:stage_eq => "lost"}
        # Uses :methods => :name, in case name is aliased to return #id - #name
        expect(response.body).to eql([lost].to_xml(only: [], methods: [:id, :name]))
      end
    end
  end
end
