[Account, Campaign, Contact, Lead, Opportunity, Task].each do |model|

  controller = (model.name.pluralize + 'Controller').constantize
  controller.class_eval do

    skip_before_filter :require_user, :only => :meta_search
    before_filter :require_application, :only => :meta_search
    skip_load_and_authorize_resource :only => :meta_search

    def meta_search
      # TODO: need param santization. Currently full method access is available!
      @only  = params[:only] || [:id, :name]
      @only.unshift(:id) unless @only.map(&:to_sym).include?(:id)
      @limit = params[:limit] || 10

      @results = []
      unless params[:search].blank?
        if params[:search][:text_search]
          @results = klass.text_search(params[:search][:text_search]) # ffcrm internal search
        else
          @results = klass.search(params[:search]).result(:distinct => true) # ransack
        end
        @results = @results.all(:limit => @limit)
      end
      
      options = {:only => [], :methods => @only}
      options.deep_merge!(:include => { :account => { :only => [:id, :name] } }) if klass == Contact
      respond_to do |format|
        format.json { render :json => @results.to_json(options) }
        format.xml  { render :xml => @results.to_xml(options) }
      end
    end

    protected
    
    #
    # DEPRECATED - THESE FUNCTIONS ARE NOT LONGER USED
    #
    # We will factor both functions out into ffcrm_merge so that you can query which objects have been merged.
    # e.g. a result of {'3' => '6'} should tell you that item id 3 has been merged into item id 6 and
    # therefore you should update all ids of 3 to 6.
    #
    def replace_aliases
      if defined?(ContactAlias) and klass == Contact and params[:search] and params[:search][:id_in]
        params[:search][:id_in] = ContactAlias.ids_with_alias(params[:search][:id_in]).values.uniq
      end
    end
    
    #
    # Contact Alias stuff should be refactored out into ffcrm_merge and called via a hook
    # perhaps there is a better place to hook in altogether
    #
    def factor_aliases(results)
      
      return results unless defined?(ContactAlias)
      
      new_results = []
      if params[:search][:id_in]
        alias_id_hash = {}
        # Iterate through search ids and the current asset id (for merged assets).
        alias_id_hash.each do |search_id, current_id|
          # If the search results contain the search id, add to new_results.
          if record = results.detect{|record| record.id == results.to_i }
            new_results.delete(klass.find(record.id))
            new_results << klass.find(search_id)
          # Else, if the search results don't contain the search id,
          # but the search results do contain the current id, change the current
          # id back to the old id and add to new_results.
          elsif record = results.detect{|record| record.id == current_id.to_i }
            record_with_old_id = record.dup
            record_with_old_id.id = search_id
            new_results << record_with_old_id
          # Finally, if no record exists then object has been destroyed, not merged
          # so return a new 'deleted' object.
          else
            deleted_params = case klass.name
              when 'Account', 'Campaign', 'Opportunity', 'Task'
                {:name => "[Deleted #{klass.name}]"}
              when 'Contact', 'Lead'
                {:first_name => "[Deleted", :last_name => "#{klass.name}]"}
              else
                {}
              end
            obj = klass.new(deleted_params)
            obj.id = search_id
            new_results << obj
          end
        end
      else
        # Else, if we are just searching for a single record by id
        new_results = results

        # If we are using the crm_merge plugin, we also need to duplicate a returned
        # contact into a list including ancestors, in case the external application
        # contains an entry with a merged id.
        # (only if we are searching for a specific ID, though)
        if defined?(ContactAlias) and params[:search][:id_equals] and new_results.any?
          contact = new_results.first.dup
          ContactAlias.find_all_by_contact_id(contact.id).each do |ancestor|
            contact.id = ancestor.destroyed_contact_id
            new_results << contact
          end
        end
      end
      
      new_results
    end

  end
end
