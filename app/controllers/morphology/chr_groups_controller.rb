class Morphology::ChrGroupsController < ApplicationController
  include Restful::Responder
  include TolkinExporter

  before_filter :params_to_hash
  before_filter :requires_project_guest, :only => [ :index, :show ]
  before_filter :requires_project_updater, :only => [ :new, :edit, :create, :update, :add_chr_to_group ]
  before_filter :requires_project_manager, :only => [ :destroy ]
  before_filter :requires_selected_project

  # GET /chr_groups
  # GET /chr_groups.xml

  auto_complete_for 'Morphology::Character', :name, :project_scope => true
  auto_complete_for 'Morphology::ChrGroup', :name, :project_scope => true

  def show_add_character
    respond_to do |format|
      format.js
    end
  end

  def remove_character
    begin
      @character = Morphology::Character.find(params[:character])
      @chr_group = Morphology::ChrGroup.find(params[:id])
      @chr_group.characters.delete(@character)
      @chr_group.updator = current_user
      @chr_group.updated_at = Time.now
      @chr_group.save!
      flash[:notice] = 'Character \'' + @character.name.to_s + '\' successfully removed.'

    rescue => e
      flash[:error] = 'Error encountered removing character.'
      log_error e
    end

    respond_to do |format|
      format.js
    end
  end

  def resource
    Morphology::ChrGroup
  end

  def index
    query_params_provided? ||
      params.merge!(
        include: :creator,
        order: [ :name ],
        limit: 20
      )
    super(current_project.chr_groups)
  end

  # GET /chr_groups/1
  # GET /chr_groups/1.xml
  def show
    @project = current_project
    @chr_group = Morphology::ChrGroup.find(params[:id])
    @characters = @chr_group.characters

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @chr_group }
    end
  end

  # GET /chr_groups/new
  # GET /chr_groups/new.xml
  def new
    @chr_group = Morphology::ChrGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @chr_group }
      format.js
    end
  end

  # GET /chr_groups/1/edit
  def edit
    @project = Project.find(params[:project_id])
    @chr_group = Morphology::ChrGroup.find(params[:id])
  end

  # POST /chr_groups
  # POST /chr_groups.xml
  def create
    @attributes_to_show = [ :creator ]
    @attribute_display_properties = {
      :creator => { :label => 'Added by',
        :display_attribute => ['first_name', 'last_name'] }
    }
    new_chr_group_hash = params[:chr_group]
    new_chr_group_hash[:creator_id] = @current_user.id
    new_chr_group_hash[:updator_id] = @current_user.id
    new_chr_group_hash[:project_id] = params[:project_id]

    @chr_group = Morphology::ChrGroup.new(params[:chr_group])

    respond_to do |format|
      if @chr_group.save
        flash[:notice] = 'ChrGroup was successfully created.'
        format.html { redirect_to project_morphology_chr_groups_path(params[:project_id]) }
        format.xml  { render :xml => @chr_group, :status => :created, :location => @chr_group }
        format.js
      else
        flash[:error] = 'Error creating Character Group.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @chr_group.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    @chr_group = Morphology::ChrGroup.find(params[:id])

    respond_to do |format|
      if @chr_group.update_attributes(params[:morphology_chr_group])
        flash[:notice] = 'ChrGroup was successfully updated.'
        format.html { redirect_to project_morphology_chr_group_path(current_project, @chr_group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @chr_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @chr_group = Morphology::ChrGroup.find(params[:id])
    @chr_group.destroy

    respond_to do |format|
      format.html { redirect_to project_morphology_chr_groups_path(params[:project_id]) }
      format.xml  { head :ok }
    end
  end

  #TODO: Error checking
  def change_position
    debugger
    @project = current_project
    @move_type = params[:move_type]
    @chr_group = Morphology::ChrGroup.find(params[:id])
    @character = @chr_group.characters.find(params[:character_id])
    character_chr_group = @chr_group.characters_chr_groups.find_by_character_id(params[:character_id])
    max_position = @chr_group.characters.maximum(:position)
    @prev_first_character = @chr_group.characters.find(:first, :conditions => ["characters_chr_groups.position = 1"])
    @prev_last_character = @chr_group.characters.find(:first, :conditions => ["characters_chr_groups.position = ?", max_position])
    character_chr_group.send(@move_type)
    @prev_character = character_chr_group.higher_item.try(:character)
    @next_character = character_chr_group.lower_item.try(:character)
    @first_character = @chr_group.characters.find(:first, :conditions => ["characters_chr_groups.position = 1"])
    @last_character = @chr_group.characters.find(:first, :conditions => ["characters_chr_groups.position = ?", max_position])
    @is_at_bottom = true if character_chr_group.last?
    @is_at_top = true if character_chr_group.first?

    respond_to do |format|
      format.html {redirect_to(project_morphology_chr_group_path(@project, @chr_group))}
      format.xml {head :ok}
      format.js
    end
#    @project = current_project
#    @move_type = params[:move_type]
#    @chr_group = @project.chr_groups.find(params[:id])
#    @character = @chr_group.characters.find(params[:character_id])
#    character_chr_group = @chr_group.characters_chr_groups.find_by_character_id(params[:character_id]);
#    character_chr_group.send(@move_type)
#
#    @prev_character = @character.higher_item
#    @next_character = @character.lower_item
#
#    @is_at_bottom = true if @character.last?
#    @is_at_top = true if @character.first?
#
#    respond_to do |format|
#      format.html { redirect_to(project_chr_group_path(@project, @chr_group)) }
#      format.xml  { head :ok }
#      format.js
#    end
  end

  # Add an already existing character to the selected character group.
  def add_character
    begin
      @project = current_project
      @chr_group = Morphology::ChrGroup.find(params[:id])
      @character = @project.characters.main.with_name_like(params[:character][:name]).first

      raise "Character '#{params[:character][:name]}' not found." if @character.nil?
      raise "Character '#{@character.name}' already in group." if @chr_group.characters.include?(@character)

      @chr_group.characters << @character
      flash[:notice] = "Character '#{@character.name}' added successfully."
    rescue RuntimeError => e
      flash[:error] = e.to_s
    rescue => e
      flash[:error] = "Error in adding character."
      log_error e
    end

    respond_to do |format|
      format.js
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

  def full_name(creator_id)
    return  Person.find(:all, ({
          :select => 'people.last_name, people.first_name',
          :conditions => [ "people.id = ?", creator_id ]
        }))

  end

  #TODO needs to be fixed
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
              chr_group = Morphology::ChrGroup.find(group_id)

              unless chr_group.nil?
                chr_group.characters.each { |chr|
                  success = matrix.characters << chr unless matrix.otus.include?(chr)
                }
              end
            }
            flash[:notice] = "Characters in the group added to Matrix."
          elsif matrix_id == "-1" and !(matrix_name.nil? or matrix_name.blank?)
            matrix = Morphology::Matrix.new(:name => matrix_name, :project_id => params[:project_id], :creator_id => current_user.id, :updator_id => current_user.id)
            matrix.save

            selected_group_array.each { |group_id|
              chr_group = Morphology::ChrGroup.find(group_id)

              unless chr_group.nil?
                chr_group.characters.each { |chr|
                  matrix.characters << chr
                }
              end
            }
            flash[:notice] = "Characters in the group added to Matrix."
          elsif matrix_id != "-1" and !(matrix_name.nil? or matrix_name.blank?)
            flash[:notice] = "Either select a Matrix or Enter a Matrix Name.  Can't do both simultaneously."
          elsif matrix_id == "-1" and (matrix_name.nil? or matrix_name.blank?)
            flash[:notice] = "Either select a Matrix or Enter a new Matrix Name."
          end

        else
          flash[:notice] = 'No Character Groups selected.  Please select Character Group and try again.'
        end
      end

    rescue
      flash[:notice] = 'Error Processing Request.  This error has been Notified and will be addressed soon.'
      #TODO: Log / Notify Error
    end

    respond_to do |format|
      format.html { redirect_to(project_morphology_chr_groups_path(params[:project_id])) }
      format.xml  { render :xml => @otu }
      format.js
    end
  end

  def delete_selected
    super current_project.chr_groups
  end

  def remove_selected
    chrs_to_be_deleted = params[:chr_ids]
    success = false
    begin
      Morphology::ChrGroup.transaction do
        unless chrs_to_be_deleted.nil?

          if chrs_to_be_deleted.size == 0
            flash[:notice] = 'No Characters selected.  Please select Character(s) and try again.'
          else
            chr_group = Morphology::ChrGroup.find(params[:chr_group_id])
            chrs_to_be_deleted.each { |chr_id|
              chr = Morphology::Character.find(chr_id)
              success = chr_group.characters.destroy(chr) if chr_group.characters.include?(chr)
            }

            if success
              flash[:notice] = 'Characters removed from group.'
            else
              flash[:notice] = 'Error Processing Request.  This error has been Notified and will be addressed soon.'
              #TODO: Log / Notify Error
            end

          end
        else
          flash[:notice] = 'No Characters selected.  Please select an Character(s) and try again.'
        end
      end
    rescue
      flash[:notice] = 'Error Processing Request.  This error has been Notified and will be addressed soon.'
      #TODO: Log / Notify Error
    end

    respond_to do |format|
      format.html { redirect_to(project_morphology_chr_group_path(params[:project_id], params[:chr_group_id]) ) }
      format.xml  { render :xml => @chr }
      format.js
    end
  end


end
