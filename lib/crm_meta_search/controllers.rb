[Account, Campaign, Contact, Lead, Opportunity, Task].each do |model|

  controller = (model.name.pluralize + 'Controller').constantize
  controller.class_eval do

    skip_before_filter :require_user, :only => :meta_search
    before_filter :require_application, :only => :meta_search

    def meta_search
      alias_id_hash = {}
      if params[:search][:id_in]
        # Sanitizes params search ids, replaces deleted / merged contact ids
        # with current ids.
        alias_id_hash = ContactAlias.ids_with_alias(params[:search][:id_in])
        params[:search][:id_in] = alias_id_hash.values.uniq
      end

      # Find all records that match our sanitized id set.
      @search = klass.metasearch(params[:search])
      @only = params[:only] || [:id, :name]
      @limit = params[:limit] || 10

      @search = @search.all(:include => params[:include], :limit => @limit)

      @results = []
      # Iterate through search ids and the current asset id (for merged assets).
      alias_id_hash.each do |search_id, current_id|
        # If the search results contain the search id, add to results.
        if record = @search.detect{|record| record.id == search_id.to_i }
          @results << record.dup
        # Else, if the search results don't contain the search id,
        # but the search results do contain the current id, change the current
        # id back to the old id and add to results.
        elsif record = @search.detect{|record| record.id == current_id.to_i }
          record_with_old_id = record.dup
          record_with_old_id.id = search_id
          @results << record_with_old_id
        # Finally, if no record exists (asset has been destroyed, not merged),
        # create a new 'deleted contact' for the asset.
        else
          contact = Contact.new(:first_name => "[Deleted", :last_name => "Contact]")
          contact.id = search_id
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

