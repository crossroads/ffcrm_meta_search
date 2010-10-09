[Account, Campaign, Contact, Lead, Opportunity, Task].each do |model|

  controller = (model.name.pluralize + 'Controller').constantize
  controller.class_eval %Q{
    before_filter :require_user, :except => :meta_search

    def meta_search
      @search = #{model}.metasearch(params[:search])
      @only = params[:only] || [:id, :name]
      @limit = params[:limit] || 10

      @results = @search.all(:limit => @limit)

      respond_to do |format|
        format.json { render :json => @results.to_json(:only => [false], :methods => @only) }
        format.xml  { render :xml => @results.to_xml(:only => [false], :methods => @only) }
      end
    end
  }
end
