require 'restful/responder'
class Library::PublicationsController < ApplicationController

  include Restful::Responder
  # index, show, new, edit, create, update, destroy
  before_filter :requires_selected_project
  before_filter :requires_project_guest, :only => [ :index, :show ]
  before_filter :requires_project_updater, :only => [ :new, :create, :edit, :update ]
  before_filter :requires_project_manager, :only => [ :destroy ]

  # GET /publications
  # GET /publications.xml
  def index
    params.include?(:limit) or params[:limit] = 20
    respond_to_index_request_searchlogic(current_project.publications)
#    @publications = Library::Publication.find(:all, :conditions=>["project_id = ? ",params[:project_id]])
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @publications }
#    end
  end

  # GET /publications/1
  # GET /publications/1.xml
  def show
    @publications = current_project.publications.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @publications }
    end
  end

  # GET /publications/new
  # GET /publications/new.xml
  def new
    @publication = Library::Publication.new

    @publishers = Library::Publisher.all
    @publisher_sources = Library::PublisherSource.all
    @publications = Library::Publication.all

    respond_to do |format|
      format.js { render 'new.html.erb', layout: request.xhr? ? false : true }
      #format.html # new.html.erb
      #format.js  { render :xml => @publication }
    end
    
  end
  
  def show
    @publication = current_project.publications.find(params[:id])

    @publishers = Library::Publisher.all
    @publisher_sources = Library::PublisherSource.all
    @publications = Library::Publication.all
    super current_project.publications 
    #respond_to do |format|
    #  format.html{ render 'show', layout: request.xhr? ? false : true }
    #end
  end
  # GET /publications/1/edit
  def edit
    @publication = current_project.publications.find(params[:id])

    @publishers = Library::Publisher.all
    @publisher_sources = Library::PublisherSource.all
    @publications = Library::Publication.all
  end

  # POST /publications
  # POST /publications.xml
  def create
    @publication = current_project.publications.new(params[:publication])
    @publication.project_id = params[:project_id]
    respond_to do |format|
      if @publication.save
        flash[:notice] = 'Publications was successfully created.'
        format.html { redirect_to(project_library_publications_path(params[:project_id])) }
        format.xml  { render :xml => @publication, :status => :created, :location => @publication }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @publication.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /publications/1
  # PUT /publications/1.xml
  def update
    @publications = current_project.publications.find(params[:id])

    respond_to do |format|
      if @publications.update_attributes(params[:publication])
        flash[:notice] = 'Publications was successfully updated.'
        format.html { redirect_to(project_library_publications_path(params[:project_id])) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @publications.errors, :status => :unprocessable_entity }
      end
    end
  end

    def delete_selected
    @publisher = current_project.publications.destroy(current_project.publications.find(params[:data]))
    respond_to do |format|
      format.html do
        flash[:notice] = 'Publications was successfully deleted.'
        redirect_to(project_library_publications_path(params[:project_id]))
      end
    end
  end

  # DELETE /publications/1
  # DELETE /publications/1.xml
  def destroy
    @publications = current_project.publications.find(params[:id])
    @publications.destroy
    flash[:notice]="Publication deleted succesfully"
    respond_to do |format|
      format.html { redirect_to(project_library_publications_path(params[:project_id])) }
      format.xml  { head :ok }
    end
  end

  def publications_search
    @publications = Library::Publication.find(:all,:conditions=>["name ILIKE ? and project_id = ?", "%#{params[:search]}%",params[:project_id]] , :order => "name")
    render :partial => "pub_drpdwn_list"
  end

end
