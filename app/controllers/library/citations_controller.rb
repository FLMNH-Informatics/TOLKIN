require 'restful/responder'

class Library::CitationsController < ApplicationController

  include Restful::Responder
  include BulkUploader


  before_filter :params_to_hash
  before_filter :requires_selected_project
  before_filter :requires_project_guest, :only => [ :index, :show, :getfile,
    :contributorships_author_search,
    :publications_search, :citations_search ]
  before_filter :requires_project_updater, :only => [ :new, :edit, :create, :update,
    :bulk_create, :bulk_upload,
    :add_new_authors, :add_author ]
  before_filter :requires_project_manager, :only => [ :destroy ]

  before_filter :get_project, :only => [:show, :new, :update, :create]

  def show_new_upload
      super resource
    end

    def new_upload
      super resource
    end

    def bulk_upload
      super resource
    end

    def view_map
      super
    end

    def resource
      Library::Citation
    end

  def index
    params[:conditions] &&
      params[:conditions].gsub!(/\[authors\]/, '[contributorships.author.name]')
      #params[:conditions].gsub!(/\[authors\]/, '[contributorships.person.last_name]')

    params[:conditions] &&
      params[:conditions].gsub!(/\[publication\]/, '[publication.value]')

    params[:conditions] &&
      params[:conditions].gsub!(/\[publisher\]/, '[publisher.name]')
      
    query_params_provided? ||
      params.merge!({
        select: [
          :id,
          :authors_joined,
          #:'contributorships.person.first_name',
          #:'contributorships.person.last_name',
          :'year',
          :'title',
          :publication_id,
          :publisher_id,
        ],
        joins: [
          'LEFT OUTER JOIN "contributorships" ON ("contributorships"."citation_id" = "citations"."id"  AND "contributorships"."position" = 1)',
          'LEFT OUTER JOIN "authors" ON "authors"."id" = "contributorships"."author_id"',
          :publication.outer,
          :publisher.outer,
        ],
        include: [
          publication: { select: [ :l_publication_id, :value ]},
          publisher: { select: [ :id, :name ]},
          #{ :contributorships => :person }
          contributorships: { 
            include: {
              author: { select: [ :id, :name ] }
            }
          }
        ],
        limit: 20,
        order: [
          'contributorships.position',
          #:'contributorships.person.last_name',
          'authors.name',
          'l_publications.value',
          'publishers.name'
        ]
      })
    super(current_project.citations)
  end

  # shows a citation
  def show
    query_params_provided? ||
      params.merge!(
        joins: :contributorships.outer,
        order: { contributorships: :position },
        include: {
          contributorships: {
            include: {
              author: {
                select: [ 'id', 'name' ]
        }}}}
      )
    super current_project.citations

  end
  
  def new
    super current_project.citations
  end

  def new_two
    # renders a page for new citations
    if params[:citation].nil?
      params[:citation] = {};
      params[:citation][:type]= params[:citation_type]
    end
    @citation = "Library::#{params[:citation][:type]}".constantize.new(params[:citation].merge(project_id: current_project.id))
    @citation.type = "Library::#{params[:citation][:type]}"
    respond_to do |format|
      format.html { render 'new_two', layout: request.xhr? ? false : 'application' }
      format.xml  { render :xml => @citation }
    end
  end

  #getting the files for citations
  def getfile
    # TODO: needs to be restricted on a per user basis
    unless params[:id]
      redirect_to :action => 'index'
      return
    end
    citation = current_project.citations.find(params[:id])
    citfile = citation.citation_file
    send_file "#{LIBRARY_PUBLICATION_ATTACHMENT_STORAGE_PATH}/#{citation.id}/#{citfile.name}", :disposition => 'inline'
  end

  def create
    params[:citation][:contributors] = force_utf(params[:citation][:contributors]) if params[:citation].try(:[],'contributors')
    remove_names_param if params[:citation].try(:[],'contributors').try(:[],'names')

    @status = Library::Citation.create_with(params[:citation], current_user, current_project) ? 'success' : 'failure'

#    Library::Citation.transaction do
#      handle_title params[:citation], :book
#      handle_title params[:citation], :series
#      @citation =
#        params[:citation].
#          delete(:type).
#          constantize.
#          create!(
#            params[:citation].
#              merge(project_id: current_project.id)
#          )
#    end
    respond_to do |format|
      format.html { render text: "<html><body><span id='citation_status'>#{@status}</span></body></html>" }
    end

#      if @citation.save
#        respond_to do |format|
#          flash[:notice] = 'Citation created successfully.'
#          format.html { redirect_to :action => 'index' }
#          format.js do
#            responds_to_parent { render 'create.rjs' }
#          end
##          format.js do
##            responds_to_parent {  render :partial => "new.html.erb",:locals => {:url => project_library_citations_path(params[:project_id] ,:format => :js)}, :layout=>false }
##          end
##          format.html { redirect_to :action => 'index' }
#        end
#      else
#        respond_to do |format|
#          format.js do
#            responds_to_parent { render }
#          end
#          format.html { render :action => "new" }
#          format.xml  { render :xml => @citation.errors, :status => :unprocessable_entity }
#        end
#      end
#    end
  end

  def update
    params[:citation][:contributors] = force_utf(params[:citation][:contributors]) if params[:citation].try(:[],'contributors')
    remove_names_param if params[:citation].try(:[],'contributors').try(:[],'names')
    @citation = params[:citation][:type].constantize.find_by_id_and_project_id(params[:id], current_project.id)
    @status   = @citation.update_with(params[:citation], current_user, current_project) ? 'success' : 'failure'
#    Library::Citation.transaction do
#      @citation.update_with_dependencies(params, current_user, current_project)
#      params.delete(:pubfile)
#      @status = @citation.save! ? 'success' : 'failure'
#    end
    flash[:notice] = "Citation updated"
    respond_to do |format|
      format.html { render text: "<html><body><span id='citation_status'>#{@status}</span></body></html>" }
    end
  end

  def destroy
    @citation = current_project.citations.find(params[:id])
    @citation.destroy
    flash[:notice] = 'Citation was successfully deleted.'
    respond_to do |format|
      format.html { redirect_to(project_library_citations_url(params[:project_id])) }
      format.xml  { head :ok }
    end
  end

  def delete_selected
    super current_project.citations
  end
=begin
  def bulk_create
    @new_citations, @records = Library::Citation.bulk_create(params)
    flash[:notice] = "Bulk Upload Done, #{@new_citations.size} records uploaded."
    redirect_to(project_library_citations_url(params[:project_id]))
  end
  
  def bulk_upload
  end
=end
  def add_new_authors
    params.merge!(
      select: [ :*, :name_citation_formatted ]
    )
    @resource = current_project.people
    @author = @resource.find(params[:contributorships][:author_id], select: 'id, last_name, first_name')
    #render :partial => "author", :layout => false, :locals => {:author => @author}
    respond_to do |format|
      format.json { render json: @author}#.to_json(methods: :name_citation_formatted) }
    end
  end

  def contributorships_author_search
    @people = current_project.people.find(:all,:conditions=>["last_name ILIKE ?", "%#{params[:search]}%"], :order => "last_name")
    render :partial => "drpdwn_list"
  end

  # TODO: possibly remove this method.  is this being used anywhere?
  def citations_search
    @citations = current_project.citations.find(:all,:conditions=>["title ILIKE ?", "%#{params[:search]}%"] , :order => "title")
    render :partial => "shared/citation"
  end

  #being called fromt the custom/advanced search
  def citation_custom_search
    @results = Library::Citation.citation_advanced_search(current_project, params)
    render :update do |page|
      page.replace_html "div_citation_list#{params[:id]}", :partial => "citations", :object => @results
    end
  end

  def search
  end

  def citation_add
    render(:update) do |page|
      page.insert_html :bottom, 'span_citation_list', :partial=>"shared/citation", :collection => params[:citation_ids]
    end
  end

  def add_author name
    @author = Library::Author.create({:name => name, :project_id => params[:project_id]})
  end

  def check_author
    @author = Library::Author.find_by_name(params[:name], :conditions => {:project_id => params[:project_id]}, :limit => 1)
    if @author == nil
      @author = {:author => {:name => params[:name], :id => params[:name] }}
    end
    respond_to do |format|
      format.json { render json: @author.to_json }
    end
  end
  
  private
  def force_utf hash_to_force
    hash_to_force.inject({}) do |hash, (key,value)|
      if key.kind_of?(String)
        key = key.to_s.dup.force_encoding('utf-8')
      else
        key = key
      end
      if value.kind_of?(String)
        hash[key] = value.to_s.dup.force_encoding('utf-8')
      elsif value.kind_of?(Hash)
        hash[key] = force_utf(value)
      else
        hash[key] = value
      end
      hash
    end
  end

  def get_project
    @project = current_project
  end

  def remove_names_param
    params[:citation][:contributors][:names].each do |key,val|
      if key == val
        #adds author to db
        auth = add_author val
        params[:citation][:contributors][:ids].delete(val)
        params[:citation][:contributors][:ids] << auth.id
        params[:citation][:contributors][:positions][auth.id] = params[:citation][:contributors][:positions].delete(val)
      end
    end
    params[:citation][:contributors].delete(:names)
  end
end
