[Account, Campaign, Contact, Lead, Opportunity, Task].each do |model|

  controller = (model.name.pluralize + 'Controller').constantize
  controller.class_eval %Q{
    before_filter :require_user, :except => :meta_search

    def meta_search
      @search = #{model}.metasearch(params[:search])
      @select = params[:select] || :name
      @limit = params[:limit] || 10

      @results = @search.all(:select => @select, :limit => @limit)

      respond_to do |format|
        format.json { render :json => @results }
        format.xml  { render :xml => @results }
      end
    end
  }
end
