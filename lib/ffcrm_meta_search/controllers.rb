
module FfcrmMetaSearch
  module Controllers

    extend ActiveSupport::Concern

    included do

      skip_before_action :authenticate_user!, only: :meta_search
      before_action :require_application, only: :meta_search
      skip_load_and_authorize_resource only: :meta_search

      def meta_search
        # TODO: need param santization. Currently full method access is available!
        @only  = params["only"] || %w(id name)
        @only.unshift("id") unless @only.include?("id")
        @limit = params["limit"] || 10

        @results =
          if params["search"].blank?
            [] # return nothing if no search
          elsif params["search"]["text_search"]
            klass.text_search(params["search"]["text_search"]).limit(@limit) # ffcrm internal search
          else
            klass.ransack(params["search"]).result(distinct: true).limit(@limit) # ransack
          end

        options = {only: [], methods: @only}
        options.deep_merge!(include: { account: { only: %w(id name) }, account_contact: {only: %w(id account_id title department)} }) if klass == Contact

        Rails.logger.debug "Finished CRM Search, sending back #{@results.to_json(options)}" if Rails.env.development?

        respond_to do |format|
          format.json { render json: @results.to_json(options) }
          format.xml  { render xml: @results.to_xml(options) }
        end
      end

      protected

      #----------------------------------------------------------------------------
      def klass
        @klass ||= controller_name.classify.constantize
      end

      # rudimentary API KEY authentication for the aliases action
      def require_application
        error = ""
        if !Setting.ffcrm_meta_search.present?
          error = 'No api key defined in Setting.ffcrm_meta_search. Rejecting all requests.'
        elsif !params["api_key"].blank? && params["api_key"] == Setting['ffcrm_meta_search']['api_key']
          return true # skip the error rendering
        else
          error = 'Please specify a valid api_key in the url.'
        end
        render js: {errors: error}.to_json
        false
      end

    end

  end
end
