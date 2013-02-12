class OtuGroupsController < ApplicationController
  include Restful::Responder
  include TolkinExporter

  before_filter :params_to_hash
  # index, show, new, edit, create, addotutogroup, update, destroy, removeotu
  before_filter :requires_selected_project
  before_filter :requires_project_guest, :only => [ :index, :show ]
  before_filter :requires_project_updater, :only => [ :new, :create, :edit, :update, :addotutogroup, :destroy, :removeotu ]

  #TODO dirty hack - remove this once you have a non-hackish way to access removeotu function up and running
  protect_from_forgery :only => [:create, :update, :destroy]

  auto_complete_for :otu, :name, :project_scope => true
  auto_complete_for :otu_group, :name, :project_scope => true

  def index
    query_params_provided? ||
      params.merge!(
        include: {creator: {select: [:user_id, :full_name]}},
        order: [ :name ],
        limit: 20
      )
    super(current_project.otu_groups)
  end

  def resource
    OtuGroup
  end

  def show_add_otu
    @otu = current_project.otus.new
    @otu_group = current_project.otu_groups.find(params[:id])
    respond_to do |format|
      format.html { render 'show_add_otu', layout: request.xhr? ? false : true }
    end
  end

  def show
    @otu_group =
      OtuGroup.scoped.apply_finder_options(
        include: { updator: { select: [ :user_id, :first_name, :last_name ]},
          creator: { select: [ :user_id, :first_name, :last_name ]}
        }
      ).find(params[:id])
    @otus = @otu_group.otus
    @project = current_project

    #max_position = @otu_group.otus.maximum(:position)
    #@first_otu = @otu_group.otus.find(:first, :conditions => ["otu_groups_otus.position = 1"])
    #@last_otu = @otu_group.otus.find(:first, :conditions => ["otu_groups_otus.position = ?", max_position])

    respond_to do |format|
      format.html { render :html => 'show' , :layout => true }# show.html.erb
      format.xml  { render :xml  => @otu_group }
      format.json { render :json => @otu_group }
    end
  end

  def new
    @otu_group = OtuGroup.new
    respond_to do |format|
      format.html { render :partial => 'new_otu_group'}# new.html.erb
      format.xml  { render :xml => @otu_group }
      format.js
    end
  end

  # GET /otu_groups/1/edit
  def edit
    @project = Project.find(params[:project_id])
    @otu_group = OtuGroup.find(params[:id])
  end

  # POST /otu_groups
  # POST /otu_groups.xml
  def create
    otu_group_hash = params[:otu_group_create]
    #    otu_group_hash[:creator_id] = @current_user.id
    #    otu_group_hash[:updator_id] = @current_user.id
    #    otu_group_hash[:project_id] = params[:project_id]
    #otu_group_hash[:creator_id]
    @otu_group = current_project.otu_groups.new(otu_group_hash)
    respond_to do |format|
      if @otu_group.save
        flash[:notice] = 'OtuGroup was successfully created.'
        format.html { redirect_to(project_otu_groups_path(params[:project_id])) }
        format.json { render :json => @otu_group }
        format.js
      else
        flash[:error] = 'Error creating OTU'
        format.html { redirect_to(project_otu_groups_path(params[:project_id])) }
        format.js
      end
    end
  end

  def add_to_matrix
    @matrices = Morphology::Matrix.find(:all, :conditions => "project_id = #{params[:project_id]}")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @otu }
      format.js
    end
  end

  #This function takes a array of otu groups as input and adds all the otus in
  #the group selected matrix.  If no matrix is selected and a name is entered,
  #the matrix will be created
  def add_to_matrix_update
    selected_groups = params[:selected_groups]
    selected_groups = selected_groups.strip

    matrix_name = params[:matrix][:name]
    matrix_id = params[:matrix_id]

    #Get the list of otu ids to be added to group
    selected_group_array = selected_groups.split
    success = false

    begin

      Morphology::Matrix::Checkpoint.transaction do

        if selected_group_array.length > 0

          if matrix_id != "-1" and (matrix_name.nil? or matrix_name.blank?)

            matrix = Morphology::Matrix.find(matrix_id)
            selected_group_array.each { |group_id|
              otu_group = OtuGroup.find(group_id)

              unless otu_group.nil?
                otu_group.otus.each { |otu|
                  success = matrix.otus << otu unless matrix.otus.include?(otu)
                }
              end
            }
            flash[:notice] = "OTUs in the group added to Matrix."
          elsif matrix_id == "-1" and !(matrix_name.nil? or matrix_name.blank?)
            matrix = Morphology::Matrix.new(:name => matrix_name, :project_id => params[:project_id], :creator_id => current_user.id, :updator_id => current_user.id)
            matrix.save

            selected_group_array.each { |group_id|
              otu_group = OtuGroup.find(group_id)

              unless otu_group.nil?
                otu_group.otus.each { |otu|
                  matrix.otus << otu
                }
              end
            }
            flash[:notice] = "OTUs in the group added to Matrix."
          elsif matrix_id != "-1" and !(matrix_name.nil? or matrix_name.blank?)
            flash[:notice] = "Either select a Matrix or Enter a Matrix Name.  Can't do both simultaneously."
          elsif matrix_id == "-1" and (matrix_name.nil? or matrix_name.blank?)
            flash[:notice] = "Either select a Matrix or Enter a new Matrix Name."
          end

        else
          flash[:notice] = 'No OTU Groups selected.  Please select OTU Group and try again.'
        end
      end

    rescue
      flash[:notice] = 'Error Processing Request.  This error has been Notified and will be addressed soon.'
      #TODO: Log / Notify Error
    end

    respond_to do |format|
      format.html { redirect_to(project_otus_path(params[:project_id])) }
      format.xml  { render :xml => @otu }
      format.js
    end

  end

  # Add an already existing otu to the selected otu group.
  def add_otu
    msg = nil
    begin
      @project = current_project
      @otu_group = OtuGroup.find(params[:id])
      @otu = @project.otus.active.find(:first, :conditions => ["lower(name) like ?", params[:otu][:name].downcase])
      raise "Otu '#{params[:otu][:name]}' not found." if @otu.nil?
      raise "Otu '#{@otu.name}' already in group." if @otu_group.otus_in_list.include?(@otu)
      @otu_group.otus << @otu
      flash[:notice] = "Otu '#{@otu.name}' successfully added." unless request.xhr?
    rescue RuntimeError => e
      flash[:error] = e.to_s unless request.xhr?
      msg = e.to_s
    rescue => e
      flash[:error] = "Error in adding otu." unless request.xhr?
      log_error e
      msg = e.to_s
    end
    respond_to do |format|
      format.json { render :json =>( e.nil? ? {:otu_row => render_to_string(:partial => 'otu_list_row.html.erb', :locals => {:otu => @otu })} : {:message => e.to_s } )}
    end
  end

  def add_otu_to_group
    render :html => 'add_otu_to_group', :layout => false
  end

  def update
    @otu_group = OtuGroup.find(params[:id])

    respond_to do |format|
      if @otu_group.update_attributes(params[:otu_group])
        flash[:notice] = 'OtuGroup was successfully updated.'
        format.html { redirect_to(project_otu_groups_path(params[:project_id])) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @otu_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @otu_group = OtuGroup.find(params[:id])
    if @otu_group.destroy
      flash[:notice] = 'OtuGroup deleted'
    else
      flash[:notice] = 'Error deleting OtuGroup'
    end

    respond_to do |format|
      format.html { redirect_to(project_otu_groups_path(params[:project_id])) }
      format.xml  { head :ok }
    end
  end

  #TODO: Error checking
  def change_position
    response_hash = {}
    response_hash[:msg] = nil
    begin
      @otu = current_project.otus.find(params[:otu_id])
      @otu_group = current_project.otu_groups.find(params[:id])
      otu_group_otu = OtuGroupsOtus.find_by_otu_and_otu_group(@otu,@otu_group)
      unless otu_group_otu.nil?
        if otu_group_otu.try(params[:move])
          response_hash[:msg] = 'ok'
          response_hash[:partial] = render_to_string(:partial => 'otu_list.html.erb')
        end
      end
    rescue RuntimeError => e
      log_error e
      flash[:error] = e.message unless request.xhr?
      response_hash[:msg] = e.to_s
    rescue => e
      flash[:error] = "Error encountered while moving.  Sorry for the inconvenience. #{e.message}" unless request.xhr?
      log_error e
      response_hash[:msg] = e.to_s
    end
    respond_to do |format|
      format.html { redirect_to(project_otu_group_path(@project, @otu_group)) }
      format.xml  { head :ok }
      format.js
      format.json { render :json => response_hash }
    end
  end


  def delete_selected
    super current_project.otu_groups
  end

  def remove_selected
    otus_to_be_deleted = params[:otus]
    success = false
    begin
      OtuGroup.transaction do
        unless otus_to_be_deleted.nil?

          if otus_to_be_deleted.size == 0
            flash[:notice] = 'No OTUs selected.  Please select an OTU and try again.'
          else
            otu_group = OtuGroup.find(params[:otu_group_id])
            otus_to_be_deleted.each { |otu_id|
              otu = Otu.find(otu_id)
              success = otu_group.otus.delete(otu) if otu_group.otus.include?(otu)
            }

            if success
              flash[:notice] = 'OTUs removed from group.'
            else
              flash[:notice] = 'Error Processing Request.  This error has been Notified and will be addressed soon.'
              #TODO: Log / Notify Error
            end

          end
        else
          flash[:notice] = 'No OTUs selected.  Please select an OTU and try again.'
        end
      end
    rescue
      flash[:notice] = 'Error Processing Request.  This error has been Notified and will be addressed soon.'
      #TODO: Log / Notify Error
    end

    respond_to do |format|
      format.html { redirect_to(project_otu_group_path(params[:project_id], params[:otu_group_id]) ) }
      format.xml  { render :xml => @otu }
      format.js
    end
  end

  def remove_otu
    begin
      @otu = Otu.find(params[:otu])
      @otu_group = OtuGroup.find(params[:id])
      @otu_group.otus.delete(@otu)
      @otu_group.updator = current_user
      @otu_group.updated_at = Time.now
      @otu_group.save!
      flash[:notice] = "Otu '#{@otu.name}' successfully removed."

    rescue => e
      flash[:error] = "Error encountered removing otu."
      log_error e
    end

    respond_to do |format|
      format.js
    end
  end
end
