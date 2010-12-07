[Account, Campaign, Contact, Lead, Opportunity, Task].each do |model|

  controller = (model.name.pluralize + 'Controller').constantize
  controller.class_eval do

    skip_before_filter :require_user, :only => [:meta_search]
    before_filter :require_application, :only => :meta_search

    def meta_search
      if params[:search][:id_in]
        id_hash = ContactAlias.ids_with_alias(params[:search][:id_in])
        params[:search][:id_in] = id_hash.values
      end

      @search = klass.metasearch(params[:search])
      @only = params[:only] || [:id, :name]
      @limit = params[:limit] || 10

      @results = @search.all(:include => params[:include], :limit => @limit)
      id_hash.each do |key, value|
        if result = @results.detect { |r| r.id == value.to_i }
          result.id = key # Associate merged
        else
          contact = Contact.new(:first_name => "Deleted", :last_name => "Contact")
          contact.id = key
          @results << contact
        end
      end

      respond_to do |format|
        format.json { render :json => @results.to_json(:only => [false], :methods => @only) }
        format.xml  { render :xml => @results.to_xml(:only => [false], :methods => @only) }
      end
    end

    private

    def klass
      @klass ||= self.class.name.gsub('Controller', '').singularize.constantize
    end

    def current_application_session
      @current_application_session ||= ApplicationSession.find
    end

    def require_application
      current_application_session.present?
    end
  end
end
