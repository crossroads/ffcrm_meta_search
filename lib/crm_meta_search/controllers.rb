[Account, Campaign, Contact, Lead, Opportunity, Task].each do |model|

  controller = (model.name.pluralize + 'Controller').constantize
  controller.class_eval %Q{
    skip_before_filter :require_user, :only => [:meta_search]
    before_filter :require_application, :only => :meta_search

    def meta_search
      @search = #{model}.metasearch(params[:search])
      @only = params[:only] || [:id, :name]
      @limit = params[:limit] || 10

      @results = @search.all(:include => params[:include], :limit => @limit)

      respond_to do |format|
        format.json { render :json => @results.to_json(:only => [false], :methods => @only) }
        format.xml  { render :xml => @results.to_xml(:only => [false], :methods => @only) }
      end
    end

    def current_application_session
      @current_application_session ||= ApplicationSession.find
    end

    def require_application
      current_application_session.present?
    end
  }
end
