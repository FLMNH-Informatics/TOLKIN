require 'cgi'

class SearchController < ApplicationController

  before_filter :requires_selected_project
  before_filter :requires_project_guest

  def index
    if request.get? && params[:search].nil? && params[:page].nil?
    else
      @results = Array.new
      if @results.size==0
        @count = Taxon.count(:all,:conditions => ["name ILIKE ? and project_id=?","%#{params[:search]}%",params[:project_id]])
        @results = Taxon.paginate(:all, :page => params[:page], :per_page => 20,
                                     :conditions => ["name ILIKE ? and project_id=?","%#{params[:search]}%",params[:project_id]],
        :order => "name"
        )
        #@collections = Collection.paginate(:page => params[:page], :per_page => 20,:order=>:id)
      end
    end
  end

  def search
    @searchVar = CGI::unescape(params[:search])  #this is a bug which sends an extra '=' with the raw_post
    @project = Project.find(params[:project_id])
    @results = Array.new
    if !@searchVar.nil? && !@searchVar.strip.empty?
      if params[:ajax_autocomplete]
        out_str = "<ul><li>"
        @results = @project.taxa.find(:all, :select => "name", :conditions => ["name ILIKE ?","#{@searchVar}%"], :order=> "name" )
        out_str << @results.map { |x| x.name }.join("</li><li>")
        out_str << "</li></ul>"
      else
        @results.concat(@project.taxa.find(:all, :conditions => ["name ILIKE ?","#{@searchVar}%"] , :order=> "name") )
      end
    end
    if(!params[:is_new_taxon].nil? && params[:is_new_taxon]=="true")
      is_new_taxon=true
    else
      is_new_taxon=false
    end
    if(params[:variable] == "taxon" || params[:variable] == "acceptedname" || params[:variable] == "basionym" || params[:variable] == "moveto")
      respond_to do |format|
        format.html { render(:partial=> "taxon_accepted_name_save", :locals=> { :taxi => @results, :tax_id=> params[:id], :property=>params[:variable], :is_new_taxon=> is_new_taxon}, :layout => false) }
        format.js   { render :text => out_str }
      end
    else
      respond_to do |format|
        format.js { render(:partial=> "result_list", :locals=> { :taxi => @results, :tax_id=> params[:id] , :property=>nil}, :layout => false) }
      end
    end

  end


  #would be used to decide the type of the filter to decide the type of search field added to view
  def search_filter
    column = params[:model_type].classify.constantize.columns_hash[params[:filter]]
    size = 0
    if(!column.nil?)
      if(column.type.to_s.upcase == "STRING")
        size =  column.limit
        size = 20 unless size < 20
      else
      end
    end
    #render :partial => "shared/filter_control" , :locals => {:size => size}
    render :update do |page|
      page.insert_html :bottom , "search_filter_controls#{params[:id]}", :partial => "shared/filter_control", :locals => {:size => size, :id=>params[:id]}
    end
  end

  #return would look like
  # Collection of key value pairs. one for each search. [ { key => value } , { key => value } ....]. key represents the tag for the search, value represetns the search params(after filtering) of the search
  #  [{"african_collections"=>"{\"country_like\":\"africa\"}"}, {"african_collections"=>"country_like: usa\n"}, {"african_collections"=>"county_like: alachua\n"}, {"african_collections"=>"country_like: africa\n"}, {"african_collections"=>nil}]
 def past_searches
   # current_user.advanced_searches.for_model_by_project(params[:model_name], current_project.id, 5)
   t = current_user.advanced_searches.for_model_by_project(params[:model_name], current_project.id, 5).collect do |search|
    { Tagging.find_by_taggable_type_and_taggable_id("AdvancedSearch",  search.id ).tag.name => search.params }
    end
   render :json => t.to_json
 end
end
