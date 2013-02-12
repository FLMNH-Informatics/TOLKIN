class NexusDatasetsController < ApplicationController
  # GET /nexus_datasets
  # GET /nexus_datasets.xml

  before_filter :requires_selected_project
  before_filter :requires_project_guest, :only => [ :index, :show ]
  before_filter :requires_project_updater, :only => [ :new, :edit, :create, :update ]
  before_filter :requires_project_manager, :only => [ :destroy ]

  def index
    @nexus_datasets = NexusDataset.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nexus_datasets }
    end
  end

  def show
    @nexus_dataset = NexusDataset.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nexus_dataset }
    end
  end

  def new
#    @project = current_project
#    @nexus_dataset = NexusDataset.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @nexus_dataset }
#      format.js
#    end
  end

  def edit
    @nexus_dataset = NexusDataset.find(params[:id])
  end

  def create
    @project = current_project
    begin
      Morphology::Matrix.transaction do
        nd = {:project_id => @project.project_id, :filename => params[:nexus_dataset][:uploaded_data].original_filename, :content_type => params[:nexus_dataset][:uploaded_data].content_type }
        @nexus_dataset = NexusDataset.create!(nd)
        options = {}
        ##for submatrix
        #parent_branch = @project.branches.find(:first, :conditions => ["lower(name) LIKE lower(?)", params[:parent_name]]) if params[:import_as] == 'submatrix'
        raise "parent matrix for submatrix being imported not found" if params[:import_as] == 'submatrix' && !parent_branch
        options[:parent_id] = parent_branch.id if params[:import_as] == 'submatrix' && parent_branch
        @timeline = @nexus_dataset.nexus_to_db(@current_user, @current_project, params[:matrix][:name],params[:nexus_dataset][:uploaded_data].tempfile, options)
        flash[:notice] = 'Nexus file imported successfully'
      end
    rescue => e
      log_error e
      flash[:error] = "Error Uploading Nexus file: #{e.message}"
    end

    params[:nexus_dataset] = nil # need to set file reference to nil to avoid "Can't dump File" error message

    respond_to do |format|
      unless flash[:error]
        format.html { redirect_to project_morphology_matrix_path(@project.project_id, @timeline.id) }
      else
        format.html { redirect_to project_morphology_matrices_path(@project) }
      end
    end
  end

  def update
    @nexus_dataset = NexusDataset.find(params[:id])

    respond_to do |format|
      if @nexus_dataset.update_attributes(params[:nexus_dataset])
        flash[:notice] = 'NexusDataset was successfully updated.'
        format.html { redirect_to(@nexus_dataset) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @nexus_dataset.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @nexus_dataset = NexusDataset.find(params[:id])
    @nexus_dataset.destroy

    respond_to do |format|
      format.html { redirect_to(nexus_datasets_url) }
      format.xml  { head :ok }
    end
  end
end
