class Library::PublishersController < ApplicationController

  include Restful::Responder
  
  before_filter :requires_selected_project
  before_filter :requires_project_guest, :only => [ :index, :show ]
  before_filter :requires_project_updater, :only => [ :new, :edit, :create, :update ]
  before_filter :requires_project_manager, :only => [ :destroy ]

  rescue_from ActiveRecord::RecordNotFound, :with => :redirect_if_not_found

  def index
    params.include?(:limit) or params[:limit] = 20
    respond_to_index_request_searchlogic(current_project.publishers)
    #    @publishers = Library::Publisher.find(:all, :conditions=>["project_id=?",params[:project_id]])
    #    respond_to do |format|
    #      format.html
    #      format.xml  { render :xml => @publishers }
    #    end
  end

  def show
    @publisher = current_project.publishers.find(params[:id])
    respond_to do |format|
      format.html {redirect_to :action=> "edit"}
      format.xml  { render :xml => @publisher }
    end
  end

  def new
    @publisher = Library::Publisher.new
  end

  def edit
    @publisher = current_project.publishers.find(params[:id])
  end

  def create
    @publisher = current_project.publishers.new(params[:publisher])
    @publisher.project_id = params[:project_id]
    @publisher.user_id = @current_user.id
    @publisher.last_updated_by = @current_user.id
    respond_to do |format|
      if @publisher.save
        flash[:notice] = 'Publisher was successfully created.'
        format.html { redirect_to(project_library_publishers_path(params[:project_id])) }
        format.xml  { render :xml => @publisher, :status => :created, :location => @publisher }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @publisher.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @publisher = current_project.publishers.find(params[:id])
    @publisher.last_updated_by = @current_user.id
    respond_to do |format|
      if @publisher.update_attributes(params[:publisher])
        flash[:notice] = 'Publisher was successfully updated.'
        format.html { redirect_to(project_library_publishers_path(params[:project_id])) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @publisher.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete_selected
    @publisher = current_project.publishers.destroy(current_project.publishers.find(params[:data]))
    respond_to do |format|
      format.html do
        flash[:notice] = 'Publishers was successfully deleted.'
        redirect_to(project_library_publishers_path(params[:project_id]))
      end
    end
  end

  def destroy
    @publisher = current_project.publishers.find(params[:id])
    @publisher.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = (!@publisher.errors.empty? && @publisher.errors.full_messages.join(', ')) || 'Publisher was successfully deleted.'
        redirect_to(project_library_publishers_path(params[:project_id]))
      end
      format.xml do
        head :ok
      end
    end
  end

  def publishers_search
    @publishers = current_project.publishers.find(:all,:conditions=>["name ILIKE ? and project_id = ?", "%#{params[:search]}%",params[:project_id]] , :order => "name")
    render :partial => "pub_drpdwn_list"
  end

  protected
  def redirect_if_not_found
    flash[:notice] = "Record Not Found"
    redirect_to(project_library_publishers_url(params[:project_id]))
  end
end
