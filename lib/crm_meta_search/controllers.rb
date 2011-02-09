[Account, Campaign, Contact, Lead, Opportunity, Task].each do |model|

  controller = (model.name.pluralize + 'Controller').constantize
  controller.class_eval do

    skip_before_filter :require_user, :only => :meta_search
    before_filter :require_application, :only => :meta_search

    def meta_search
      alias_id_hash = {}
      if params[:search][:id_in]
        alias_id_hash = ContactAlias.ids_with_alias(params[:search][:id_in])
        params[:search][:id_in] = alias_id_hash.values
      end

      @search = klass.metasearch(params[:search])
      @only = params[:only] || [:id, :name]
      @limit = params[:limit] || 10

      @results = @search.all(:include => params[:include], :limit => @limit)
      alias_id_hash.each do |asset_id, alias_id|
        if result = @results.detect { |r| r.id == asset_id.to_i } and Contact.find_by_id(alias_id)
          result.id = alias_id # Associate merged
        else
          contact = Contact.new(:first_name => "[Deleted", :last_name => "Contact]")
          contact.id = asset_id
          @results << contact
        end
      end

      respond_to do |format|
        format.json { render :json => @results.to_json(:only => [false], :methods => @only) }
        format.xml  { render :xml => @results.to_xml(:only => [false], :methods => @only) }
      end
    end

    private

    #----------------------------------------------------------------------------
    def klass
      @klass ||= self.class.name.gsub('Controller', '').singularize.constantize
    end

    #----------------------------------------------------------------------------
    def current_application_session
      @current_application_session ||= ApplicationSession.find
    end

    #----------------------------------------------------------------------------
    def require_application
      unless current_application_session
        redirect_to login_url
        false
      end
    end

  end
end

