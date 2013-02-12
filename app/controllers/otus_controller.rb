class OtusController < ApplicationController
  # GET /otus
  # GET /otus.xml

  include Restful::Responder
  include Morphology::MatricesHelper
  include TolkinExporter

  before_filter :params_to_hash

  before_filter :requires_selected_project
  #before_filter :fill_otus_list_attributes_for_index_listing, :only => [ :index ]
  before_filter :requires_project_guest, :only => [ :index, :show, :under_construction ] #FIXME: unsafe, use except instead of only
  before_filter :requires_project_updater, :except => [ :index, :show ]
    # :only => [ :new, :create, :edit, :update, :destroy, :show_add_taxon, :add_image_window ]
  auto_complete_for :otu, :name, :project_scope => true, active_scope: true
  auto_complete_for :otu_group, :name, :project_scope => true
  auto_complete_for :taxon, :name, :project_scope => true

  def resource
    Otu
  end

  def index

    query_params_provided? || 
      params.merge!(
        select: [ 'id', 'name', 'creator_id', 'otu_groups_joined' ],
        include: {
          creator: {
            select: [ 'user_id', 'label' ]
          }
        },
        limit: 20
      )
    super(current_project.otus.active)
  end

  def destroy_all
    parser = Restful::Parser.new
    current_project.otus.active.where(parser.parse(params, :conditions)).destroy_all
    head :ok
  end

  def show
    query_params_provided? ||
      params.merge!(
        include: { 
          creator: { select: [ :user_id, :full_name ] },
          updator: { select: [ :user_id, :full_name ] }
        }
      )
    super current_project.otus
#    @project = current_project
#    @otu = current_project.otus.find(params[:id])
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @otu }
#    end
  end

  def add_image_window
    @curr_otu = current_project.otus.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def show_add_taxon
    @taxon = Taxon.new
    respond_to do |format|
      format.html { render 'show_add_taxon', layout: request.xhr? ? false : 'application' }
#      format.js
    end
  end

  def add_taxon
    begin
      @old_otu_version = current_project.otus.find(params[:id])
      
      @taxon = passkey.unlock(Taxon).where(name: params[:taxon][:name_name]).first
      fail "specified taxon does not exist" unless @taxon
      @old_otu_version.transaction do
        @new_otu_version = @old_otu_version.create_clone
        @new_otu_version.taxa << @taxon
        if(params[:matrix_id])
          matrix_address = ::Matrix::Address.from_s params[:matrix_id]
          changeset = ::Matrix::Changeset.find_or_create_for(current_user, matrix_address)
          changeset.modify_y_item(@old_otu_version, @new_otu_version)
        end
      end
      @project = current_project
      @otu = @new_otu_version
      flash[:notice] = "Taxon successfully added."
    rescue => e
      flash[:error] = "Problem encountered adding taxon: #{e.message}"
    end
    respond_to do |format|
      format.html { redirect_to optional_matrix_resource_url(:controller => :otus, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id => @new_otu_version.try(:id) || @old_otu_version.id )}
      format.json { render :json => {:id => @new_otu_version.id}.to_json }
    end
  end

  def remove_taxon
    @old_otu_version = current_project.otus.find(params[:id])
    begin
      @old_otu_version.transaction do
        @new_otu_version = @old_otu_version.create_clone
        @taxon = passkey.unlock(Taxon).find(params[:taxon_id])
        @new_otu_version.taxa.delete(@taxon)
        if(params[:matrix_id])
          @matrix_address = ::Matrix::Address.from_s params[:matrix_id]
          changeset = ::Matrix::Changeset.find_or_create_for(current_user, @matrix_address)
          changeset.modify_y_item(@old_otu_version, @new_otu_version)
        end
      end
      flash[:notice] = "Taxon successfully removed."
    rescue => e
      flash[:error] = "Problem encountered removing taxon: #{e.message}"
    end
    respond_to do |format|
      format.html { redirect_to optional_matrix_resource_url(:controller => :otus, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id => @new_otu_version.try(:id) || @old_otu_version.id ) }
    end
  end

  def add_to_otu_group_wizard
    @project = current_project
    @otu_groups = @project.otu_groups.all
    respond_to do |format|
      format.html { render 'add_to_otu_group_wizard', layout: request.xhr? ? false : 'application' }
      format.xml  { render :xml => @otu }
      format.js
    end
  end

  def add_to_matrix
    @matrices = ::Matrix::Branch.find(:all, :conditions => "project_id = #{params[:project_id]}")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @otu }
      format.js
    end
  end


  # This function takes a array of otus as input and adds them all to the
  # selected matrix.  If no matrix is selected and a name is entered, the matrix
  # will be created
  def add_to_matrix_update
    selected_otus = params[:selected_otus]
    selected_otus = selected_otus.strip

    matrix_name = params[:matrix][:name]
    matrix_id = params[:matrix_id]

    #Get the list of otu ids to be added to group
    selected_otu_id_array = selected_otus.split
    success = false

    begin

      Morphology::Matrix::Checkpoint.transaction do

        if selected_otu_id_array.length > 0

          if matrix_id != "-1" and (matrix_name.nil? or matrix_name.blank?)
            matrix = Morphology::Matrix::Checkpoint.find(matrix_id)
            selected_otu_id_array.each { |otu_id|
              otu = Otu.find(otu_id)
              success = matrix.otus << otu unless matrix.otus.include?(otu)
              #TODO: Check if the following piece of code is required or not
              #              matrix.mark_join_table_record("OTU", otu.id, false, true) unless matrix.parent.nil?
              #
              #              matrix.update_otus_in_join_table(otu) if success
            }
            flash[:notice] = "OTUs Added to Matrix."
          elsif matrix_id == "-1" and !(matrix_name.nil? or matrix_name.blank?)
            matrix = Morphology::Matrix::Checkpoint.new(:name => matrix_name, :project_id => params[:project_id], :creator_id => current_user.id, :updator_id => current_user.id)
            matrix.save

            selected_otu_id_array.each { |otu_id|
              otu = Otu.find(otu_id)
              success = matrix.otus << otu unless matrix.otus.include?(otu)
              #TODO: Check if the following piece of code is required or not
              #              matrix.mark_join_table_record("OTU", otu.id, false, true) unless matrix.parent.nil?
              #
              #              matrix.update_otus_in_join_table(otu) if success
            }
            flash[:notice] = "OTUs Added to Matrix."
          elsif matrix_id != "-1" and !(matrix_name.nil? or matrix_name.blank?)
            flash[:notice] = "Either select a Matrix or Enter a Matrix Name.  Can't do both simultaneously."
          elsif matrix_id == "-1" and (matrix_name.nil? or matrix_name.blank?)
            flash[:notice] = "Either select a Matrix or Enter a new Matrix Name."
          end

        else
          flash[:notice] = 'No OTUs selected.  Please select OTUs and try again.'
        end
      end

    rescue
      flash[:notice] = 'Error Processing Request.  This error has been Notified and will be addressed soon.'
    end

    respond_to do |format|
      format.html { redirect_to(project_otus_path(params[:project_id])) }
      format.xml  { render :xml => @otu }
      format.js
    end

  end

  def add_to_group
    validate(params) && parse(params)
    @otus = (@resource = current_project.otus.active).scoped.apply_finder_options(prepare(params, for: :finder))
    begin
      OtuGroup.transaction do
        otu_name = params[:otu_group][:name]
        raise "Cannot complete add without group name. Please select a group or enter a new group name." if otu_name.blank? && params[:otu_group_id] == '-1'
        if otu_name.empty?
          @otu_group = OtuGroup.find(params[:otu_group_id])
        else
          @otu_group = OtuGroup.new :name => otu_name
          @otu_group.save
        end
        raise "No otus selected.  Could not complete add to group." if @otus.empty?
        #@otus.each { |otu| @otu_group.otus << otu unless @otu_group.otus.include?(otu) }
        @otu_group.otus = @otu_group.otus | @otus
        @otu_group.save!
        flash[:notice] = 'Otus added to group successfully.'
      end
      respond_to do |format|
        format.js { head :ok }
      end
    rescue => e
      if e.class == RuntimeError
        flash[:error] = e.to_s
      else
        log_error e
        flash[:error] = 'Error processing this request.  Notification has been received for this error.'
      end
      respond_to do |format|
        format.js { head :internal_server_error }
      end
    end
  end


  def delete_selected
    super current_project.otus.active
  end

  def new
    @otu = Otu.new
    @otu_groups = OtuGroup.find :all
    respond_to do |format|
      format.html {
        render 'new', layout: false
#        render :partial => 'new_otu', :layout => false
      }# new.html.erb
      format.xml  { render :xml => @otu }
      format.js {
        render :update do |page|
          #page["newimagediv"].show
          page.replace_html :windowdiv, :partial => "new_otu"
          page.replace_html :notice, flash[:notice]
          page.call :showWindow, :windowdiv
          page << "$('otu_name').focus();"
        end
        }
    end
  end


  def edit
    @project = Project.find(params[:project_id])
    @otu = current_project.otus.find(params[:id])
    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    @project = current_project
    otu_hash = params[:otu]
    otu_hash[:project_id] = params[:project_id]
    otu_hash[:creator_id] = @current_user.id
    otu_hash[:updator_id] = @current_user.id
    @otu = Otu.new(otu_hash)

    if params[:taxon] and params[:taxon][:name] and not params[:taxon][:name].blank?
      tax = Taxon.find_by_name(params[:taxon][:name])
    end
    #    if tax.nil?
    #      render :js => "alert('The taxon name you have entered does not correspond to an existing taxon. Please enter a name for a taxon that has already been created.');"
    #      #render :text => "Invalid Taxon"
    #    else
    @otu.taxa << tax if tax
    #    @otu.transaction do
    ##      otu_branch = OtuBranch.create!(:created_at => @otu.created_at, :creator => @otu.creator, :project => @otu.project)
    ##      @otu.update_attributes!(:version => 1, :otu_branch_id => otu_branch.id)
    #    end

    respond_to do |format|

      if @otu.save
        if not params[:otu_group_id].blank?
          @current_project.otu_groups.find(params[:otu_group_id]).otus << @otu
        end
        #@otus = Otu.find(:all)
        flash[:notice] = 'OTU was successfully created!'
        fill_otus_list_attributes_for_index_listing
        format.html { redirect_to(project_otu_path(params[:project_id], @otu)) }
        format.js
      else
        flash[:notice] = 'Error creating OTU'
        format.html { redirect_to(project_otu_path(params[:project_id], @otu)) }
        format.js { head :internal_server_error }
      end
    end
  end

  def update
    @old_otu_version = current_project.otus.find(params[:id])
    @old_otu_version.transaction do
      params[:otu][:is_working_copy] = true if params[:matrix_id]
      @new_otu_version = @old_otu_version.create_clone(params[:otu])
      if params[:taxon] and params[:taxon][:name] and not params[:taxon][:name].blank?
        @taxon = current_project.taxa.find_by_name(params[:taxon][:name])
      end
    end
    if !params[:citation_ids].nil?
      @new_otu_version.citations = current_project.citations.find(params[:citation_ids])
    else
      @new_otu_version.citations = []
    end
    if(params[:matrix_id])
      create_changeset(@old_otu_version, @new_otu_version, params[:matrix_id])
    end
    @project = current_project

    if @taxon.nil?

      respond_to do |format|
        format.html { redirect_to optional_matrix_resource_url(:controller => :otus, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id => @new_otu_version.try(:id) || @old_otu_version.id )}
        format.js   { render :js => "alert('Invalid Taxon');" }
      end
    else
      begin
        @new_otu_version.taxa << @taxon
        @otu = @new_otu_version
        flash[:notice] = "Otu successfully added."
      rescue RuntimeError => ex
        flash[:error] = "Saving Otu failed!. #{ex.message}."
      end
      respond_to do |format|
        format.html { redirect_to optional_matrix_resource_url(:controller => :otus, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id => @new_otu_version.try(:id) || @old_otu_version.id )}
      end
    end
  end

  def destroy
    begin
      @otu = current_project.otus.find(params[:id])
      if params[:matrix_id]
        matrix_address = ::Matrix::Address.from_s(params[:matrix_id])
        changeset = ::Matrix::Changeset.find_or_create_for(current_user, matrix_address)
        changeset.remove_y_item(@otu)
        @destination = project_matrix_path(current_project, params[:matrix_id])
      else
        @otu.destroy
        @destination = project_otus_path(current_project)
      end

      flash[:notice] = 'Otu successfully deleted.'
    rescue => e
      log_error e
      flash[:notice] = "Error deleting otu: #{e.message}"
    end

    respond_to do |format|
      format.html { redirect_to @destination }
      format.xml  { head :ok }
    end
  end

  def citation_add
  
    @old_otu_version = current_project.otus.find(params[:id])
    if(params[:citation_ids])
      begin
        @old_otu_version.transaction do
          @new_otu_version = @old_otu_version.create_clone(params[:otu])
          @new_otu_version.citations << current_project.citations.find(params[:citation_ids])
          if(params[:matrix_id])
            create_changeset(@old_otu_version, @new_otu_version, params[:matrix_id])
          end
          flash[:error] = "Added citations successfully."
        end
      rescue => e
        log_error e
        flash[:error] = 'Citation Addition failed!'
      end
    else
      flash[:notice] = "Please Select at least one citation."
    end

    respond_to do |format|
      format.js { 
        render(:update) do |page|
          page << %{ window.location = "#{optional_matrix_resource_url(:controller => :otus, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id =>  @new_otu_version.try(:id) || @old_otu_version.id )}" }
        end
      }
      format.html { redirect_to optional_matrix_resource_url(:controller => :otus, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id =>  @new_otu_version.try(:id) || @old_otu_version.id ) }
      format.xml  { head :ok }
    end
  end

  #  def citation_add
  #    otu = current_project.otus.find(params[:id])
  #    cit_ids = otu.citations.collect { |citation| citation.id.to_s }
  #    if params[:citation_ids]
  #      cit_ids.concat(params[:citation_ids]).uniq!
  #      otu.citations= current_project.citations.find(cit_ids)
  #      if otu.save
  #        flash[:notice] = "Added citations successfully."
  #      else
  #        flash[:error] = "Adding citations failed"
  #      end
  #    else
  #      flash[:notice]= "Please Select Atleast one citation."
  #    end
  #    respond_to do |format|
  #      format.js
  #    end
  #  end
  private

  def fill_otus_list_attributes_for_index_listing
    @attributes_to_show = [ :name, :otu_groups, :owner ]
    @attribute_display_properties = {
      :name         => {
        :link_type => 'href',
        :link => "project_otu_path(#{current_project.id}, object)"
      },
      :short_name  => { },
      :owner => { :label => 'Owner', :display_attribute => 'label' },
      :otu_groups => { :label =>  'Otu Groups', :display_attribute => 'name', :link => { :project_id => current_project.id, :action => 'show', :controller => :otu_groups }}
    }
  end

  def create_changeset(old_otu_version, new_otu_version, params_matrix_id)
    matrix_address = ::Matrix::Address.from_s params[:matrix_id]
    changeset = ::Matrix::Changeset.find_or_create_for(current_user, matrix_address)
    changeset.modify_y_item(old_otu_version, new_otu_version)
  end

  def params_to_hash
    @parameters = params.to_hash.symbolize_keys
  end
end
