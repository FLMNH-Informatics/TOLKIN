class Morphology::CharactersController < ApplicationController
  include Restful::Responder
  include Morphology::MatricesHelper
  include TolkinExporter

  # index, show, new, edit, create, update, destroy, create_state, send_email
  before_filter :requires_project_guest,   :only => [ :index, :show ]
  before_filter :requires_project_updater, :only => [ :new, :edit, :create, :update, :create_state ]
  before_filter :requires_project_manager, :only => [ :destroy, :send_email ]
  before_filter :requires_selected_project

  before_filter :params_to_hash

  auto_complete_for 'Morphology::ChrState', :name, :project_scope => true
  auto_complete_for 'Morphology::Character', :name, :project_scope => true

  ## STANDARD ACTIONS

  def resource
    Morphology::Character
  end

  def index
    query_params_provided? ||
      params.merge!(
        select: [ :id, :name, :short_name, :creator_id , :chr_groups_joined ],
        include: {
          creator: { select: :label }#,
          #characters_chr_groups: {
           # include: {
            #  chr_group: { select: :name }
          #  }
          #}
        },
        limit: 20
      )
    super(current_project.characters.active)
  end

  def show
    params.merge!(
      include: {
        creator: { select: [ :user_id, :full_name ]},
        updator: { select: [ :user_id, :full_name ]},
        chr_states: {
          include: {
            creator: { select: [ :user_id, :full_name ]},
            updator: { select: [ :user_id, :full_name ]}
          }
        }
      }
    )
    @project = current_project
    @character = (@resource = Morphology::Character).scoped.apply_finder_options(prepare(params, for: :finder)).find(params[:id])
    @chr_states = @character.chr_states
    @polarities = Morphology::ChrState.polarities
    @chr_state = Morphology::ChrState.new
    respond_to do |format|
      format.html { render 'show', layout: request.xhr? ? false : true }
      format.xml  { render :xml => @character }
    end
  end

  def new
    super current_project.characters
  end

  def attach_image
    old_chr_version = Morphology::Character.find(params[:id])
    file = {}
    file[:attachment] = params[:character].delete("uploaded_data")
    msg = nil
    unless file[:attachment].nil?
      begin
        Morphology::Character.transaction do
          @image = Image.create!(file.merge({:created_by => current_user.user_id}))
          if params[:matrix_id]
            old_chr_version.images << @image
            @character = old_chr_version
            msg = "Image successfully uploaded"
          else
            if old_chr_version.is_current
              new_chr_version = old_chr_version.create_clone
              new_chr_version.images << @image
              @character = new_chr_version
              msg = "Image successfully uploaded"
            else
              msg = 'You can only add images to the most recent version or the versions attached to matrices.'
            end
          end
          flash[:notice] = msg unless request.xhr?
          #
          #if old_chr_version.is_current
          #  if params[:matrix_id]
          #    old_chr_version.images << @image
          #    @character = old_chr_version
          #    msg = "Image successfully uploaded"
          #  else
          #    new_chr_version = old_chr_version.create_clone
          #    new_chr_version.images << @image
          #    @character = new_chr_version
          #    msg = "Image successfully uploaded"
          #  end
          #else
          #  if params[:matrix_id]
          #    old_chr_version.images << @image
          #    @character = old_chr_version
          #    msg = "Image successfully uploaded"
          #  else
          #    msg = 'You can only add images to the most recent version or the versions attached to matrices.'
          #  end
          #end
          #flash[:notice] = msg unless request.xhr?
        end
      rescue => e
        log_error e
        flash[:error] = "Error, file was not a valid image."
      end
      redirect_to params[:matrix_id] ? project_morphology_matrix_character_path(current_project.project_id, params[:matrix_id], @character.id) : project_morphology_character_path(current_project.project_id,@character.id)
    end
  end

  def remove_image
    old_chr_version = current_project.characters.find(params[:id])
    msg = 'old'
    begin
    old_chr_version.transaction do
      if old_chr_version.is_current
        new_chr_version = old_chr_version.create_clone
        new_chr_version.images = (new_chr_version.images - [Image.find(params[:image_id])])
        new_chr_version.save
        @character = new_chr_version
        msg = new_chr_version.id.to_s
        flash["notice"] = "Image successfully removed"
      else
        if params[:matrix_id]
          old_chr_version.images = (old_chr_version.images - [Image.find(params[:image_id])])
          old_chr_version.save
          @character = old_chr_version
        else
          msg = "You can only remove images from recent versions or versions attached to matrices."
          flash[:notice] = msg unless request.xhr?
        end
      end
    end
    rescue => e
      log_error e
      msg = "Error: " + e.to_s
    end
    respond_to do |format|
      format.json { render :json => {:msg => msg}}
      format.html { render 'show', layout: request.xhr? ? false : true }
    end
  end

  def create
    @project = current_project
    @character = Morphology::Character.new(params[:morphology_character])
    @character.citations = Library::Citation.find(params[:citation_ids]) if params[:citation_ids]
    @characters = current_project.characters.paginate(:page => params[:page], :per_page => 20, :order=>"name")
    fill_characters_list_attributes_for_index_listing

    respond_to do |format|
      if @character.save
        flash[:notice] = 'Character was successfully created.'
        format.html { redirect_to(project_morphology_characters_path(params[:project_id])) }
        format.xml  { render :xml => @character, :status => :created, :location => @character }
        format.js   { head :ok }
        format.json { render :json => @character.to_json }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @character.errors, :status => :unprocessable_entity }
        format.js   { head :internal_server_error }
      end
    end
  end

  def edit
    @character = Morphology::Character.find(params[:id])
    @project = Project.find(params[:project_id])
    respond_to do |format|
      format.html { render 'edit', layout: request.xhr? ? false : true }
    end
  end

  def destroy
    begin
      @character = Morphology::Character.find(params[:id])
      if params[:matrix_id]
        matrix_address = ::Matrix::Address.from_s(params[:matrix_id])
        changeset = ::Matrix::Changeset.find_or_create_for(current_user, matrix_address)
        changeset.remove_x_item(@character)
        @destination = project_morphology_matrix_path(current_project, params[:matrix_id])
      else
        @character.branch.destroy
        @destination = project_morphology_characters_path(params[:project_id])
      end

      flash[:notice] = "Character successfully deleted."
    rescue => e
      debugger
      log_error e
      flash[:notice] = "Error deleting character: #{e.message}"
    end

    respond_to do |format|
      format.html { redirect_to @destination }
      format.xml  { head :ok }
    end
  end
  ## CUSTOM ACTIONS

  def add_to_matrix
    @matrices = Morphology::Matrix.find(:all, :conditions => "project_id = #{params[:project_id]}")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @otu }
      format.js
    end

  end

  def add_to_matrix_update
    begin
      chrs_to_add = params[:selected_chrs].strip.split.collect{|id| Morphology::Character.find(id) }
      raise "no characters selected" if chrs_to_add.empty?
      branch = ::Matrix::Branch.find_by_name(params[:matrix][:name])
      raise "no matrix found for given matrix name" if branch.nil?
      address = ::Matrix::Address.from_branch_info(branch, params[:matrix][:version].to_i)
      changeset = ::Matrix::Changeset.for_user_and_address(current_user, address)

    rescue RuntimeError => e
      flash[:error] = "Error adding characters to matrix: #{e.message}"
    rescue => e
      log_error e
      flash[:error] = "Error adding characters to matrix: #{e.message}"
    end

    begin
      Morphology::Matrix::Checkpoint.transaction do
        if selected_chr_id_array.length > 0
          if matrix_id != "-1" and (matrix_name.nil? or matrix_name.blank?)

            matrix = Morphology::Matrix.find(matrix_id)
            selected_chr_id_array.each { |chr_id|
              chr = Morphology::Character.find(chr_id)
              success = matrix.characters << chr unless matrix.characters.include?(chr)
              matrix.update_otus_in_join_table(otu) if success
            }
            flash[:notice] = "Characters Added to Matrix."
          elsif matrix_id == "-1" and !(matrix_name.nil? or matrix_name.blank?)
            matrix = Morphology::Matrix.new(:name => matrix_name, :project_id => params[:project_id], :creator_id => current_user.id, :updator_id => current_user.id)
            matrix.save

            selected_chr_id_array.each { |chr_id|
              chr = Morphology::Character.find(chr_id)
              success = matrix.characters << chr unless matrix.characters.include?(chr)
            }
            flash[:notice] = "Characters Added to Matrix."
          elsif matrix_id != "-1" and !(matrix_name.nil? or matrix_name.blank?)
            flash[:notice] = "Either select a Matrix or Enter a Matrix Name.  Can't do both simultaneously."
          elsif matrix_id == "-1" and (matrix_name.nil? or matrix_name.blank?)
            flash[:notice] = "Either select a Matrix or Enter a new Matrix Name."
          end

        else
          flash[:notice] = 'No Characters selected.  Please select Characters and try again.'
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
    @chr_groups = current_project.chr_groups.find :all

    respond_to do |format|
      format.html {render :layout => false}# new.html.erb
      format.xml  { render :xml => @otu }
      format.js
    end
  end

  def add_to_group_update
    validate(params) && parse(params)
    @characters = (@resource = current_project.characters).scoped.apply_finder_options(prepare(params, for: :finder))
    begin
      Morphology::ChrGroup.transaction do
        chrgrp_name = params[:chr_group][:name]
        raise "Cannot complete add without group name.  Please select a group or enter a new group name." if chrgrp_name.blank? && params[:chr_group_id] == -1
        if chrgrp_name.empty?
          @chr_group = Morphology::ChrGroup.find(params[:chr_group_id])
        else
          @chr_group = Morphology::ChrGroup.new :name => chrgrp_name
          @chr_group.save
        end
        raise "No Characters selected. Could not complete add to group." if @characters.empty?
        @characters.each { |character| @chr_group.characters << character unless @chr_group.characters.include?(character)}
        flash[:notice] = 'Character(s) successfully added to group.'
      end
      respond_to do |format|
        format.js {head :ok}
      end
    rescue => e
      if e.class == RuntimeError
        flash[:error] = e.to_s
      else
        log_error e
        flash[:error] = 'Error processing this request. Notification has been received for this error.'
      end
      respond_to do |format|
        format.js {head :internal_server_error}
      end
    end
  end

  def character_list_attributes_and_properties
    @attributes_to_show = [ :name, :short_name, :creator ]
    @attribute_display_properties = {
      :name         => {
        :link_type => 'href',
        :link => "project_character_path(#{@project.id}, object.max_branch_character.to_param)"
      },
      :short_name  => { },
      :creator => { :label => 'Owner', :display_attribute => 'full_name' },
    }
  end

  def citation_custom_search
    @citations = Array.new
    if(!params[:citation].nil?)
      params[:citation].each_pair do |id, bool_value|
        if bool_value=="1"
          @citations << id
        end
      end
    end
    if(!@citations.empty?)
      render :update do |page|
        page.insert_html :after, 'div_lib_ref_list', :partial => 'citation', :collection => @citations
      end
    else
      flash[:notice] = 'No Citations were selected'
    end
  end

  def show_add_citation
    @character = current_project.characters.find(params[:id])
    respond_to{|format|format.html{render 'show_add_citation', layout: request.xhr? ? false : true}}
  end

  def citation_add
    begin
      msg = 'ok'
      partial = ""
      Morphology::Character.transaction do
        old_chr_version = current_project.characters.find(params[:id])
        cit_ids = (params[:citation_ids] - old_chr_version.citations.map{|citation| citation.id.to_s }) if params[:citation_ids]
        if old_chr_version.is_current
          new_chr_version = old_chr_version.create_clone
          cit_ids.each{|id| new_chr_version.citations << Library::Citation.find(id)}
          flash[:notice] = (cit_ids.length > 1) ? "Citations added." : "Citation added."
          msg = new_chr_version.id.to_s
          @character = new_chr_version
        else
          unless params[:matrix_id].nil?
            cit_ids.each{|id| old_chr_version.citations << Library::Citation.find(id)}
            msg = 'old'
            @character = old_chr_version
            partial = render_to_string(:partial => '/morphology/characters/character_images.html.haml', :locals => {:@character => @character})
          else
            msg = "You can only add citations to most recent versions and versions attached to matrices."
            flash[:notice] = msg unless request.xhr?
          end
        end
      end
    rescue => e
      log_error e
      msg = "Error: " + e.to_s
      flash[:notice] = msg unless request.xhr?
    end
    respond_to{|format| format.json { render :json => {:msg => msg, :partial => partial}}}
  end

  def remove_citation
    begin
      old_chr_version = current_project.characters.find(params[:id])
      msg = "ok"
      Morphology::Character.transaction do
        if old_chr_version.is_current
          new_chr_version = old_chr_version.create_clone
          new_chr_version.citations = (new_chr_version.citations - [new_chr_version.citations.find(params[:citation_id])])
          flash[:notice] = "Citation removed"
          msg = new_chr_version.id.to_s
          @character = new_chr_version
        else
          unless params[:matrix_id].nil?
            old_chr_version.citations = (old_chr_version.citations - [old_chr_version.citations.find(params[:citation_id])])
            msg = "old"
          else
            msg = "You can only remove citations from most recent versions or versions attached to matrices."
            flash[:notice] = message unless request.xhr?
          end
        end
      end
    rescue => e
      log_error e
      msg = "Error: " + e.to_s
    end
    respond_to do |format|
      format.json {render :json => {:msg => msg}}
    end
  end

  def update
    begin
      msg = 'ok'
      partial = ''
      old_chr_version = current_project.characters.find(params[:id])
      old_chr_version.transaction do
        if old_chr_version.is_current
          new_chr_version = old_chr_version.create_clone(params[:morphology_character])
          flash[:notice] = 'Character was successfully updated' unless request.xhr?
          @character = new_chr_version
          msg = @character.id.to_s
        else
          unless params[:matrix_id].nil?
            #will never come here because character_form.html.haml form has only one path
            old_chr_version.update_attributes(params[:morphology_character])
            old_chr_version.save!
            @character = old_chr_version
            msg = 'old'
          else
            msg = "You may only edit the most recent version of a character."
            flash[:notice] = msg unless request.xhr?
          end
        end
        partial = render_to_string(:partial => 'character_display.html.erb') unless @character.nil?
      end
    rescue RuntimeError => ex
      flash[:error] = "Saving Character failed!. #{ex.message}." unless request.xhr?
      msg = "Error: " + ex.to_s
    end
    respond_to do |format|
      format.json { render :json => {:character => @character, :partial => partial, :msg => msg }}
      format.html { redirect_to optional_matrix_resource_url(:controller => :characters, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id =>  @new_chr_version.try(:id) || @old_chr_version.id ) }
      format.xml  { head :ok }
    end
  end

  def create_state
    @old_chr_version = current_project.characters.find(params[:id])
    params[:morphology_chr_state][:creator_id] = current_user.user_id
    params[:morphology_chr_state][:updator_id] = current_user.user_id
    params[:morphology_chr_state][:state] = @old_chr_version.get_state_number
    msg = "ok"
    begin
      Morphology::ChrState.transaction do
        @chr_state = Morphology::ChrState.new(params[:morphology_chr_state])
        if @old_chr_version.is_current
          @new_chr_version = @old_chr_version.create_clone
          @new_chr_version.states << @chr_state
        else
          if(params[:matrix_id])
            @old_chr_version.states << @chr_state
            @character = @old_chr_version
          else
            msg = 'You can only add states to the most recent version or the versions attached to matrices.'
            flash[:notice] = msg
          end
        end
        flash[:notice] = 'State created and added!'
      end
    rescue
      flash[:notice] = 'Error in creating state'
    end
      response_hash = {}
      response_hash[:error_msg] = msg if msg != "ok"
      response_hash[:partial] = render_to_string(:partial => 'character_state.html.haml', :locals => {:state => @chr_state}) unless @old_chr_version.is_current
      response_hash[:new_character] = @new_chr_version unless @new_chr_version.nil?
    respond_to do |format|
      format.html { redirect_to optional_matrix_resource_url(:controller => :characters, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id =>  @new_chr_version.try(:id) || @old_chr_version.id ) }
      format.xml  { head :ok }
      format.js
      format.json { render :json => response_hash }
    end
  end

  def remove_state
    old_chr_version = current_project.characters.find(params[:id])
    msg = "ok"
    Morphology::ChrState.transaction do
      begin
        @chr_state = Morphology::ChrState.find(params[:chr_state_id])
        if old_chr_version.is_current
          new_chr_version = old_chr_version.create_clone
          new_chr_version.chr_states.find_by_name_and_state(@chr_state.name, @chr_state.state).destroy
          flash[:notice] = "Character state removed."
          msg = new_chr_version.id.to_s
          @character = new_chr_version
        else
          unless old_chr_version.timelines.empty?
            msg = "Error: Implement the matrix fixing"
          else
            old_chr_version.states = (old_chr_version.states - [@chr_state])
            old_chr_version.save
            @character = old_chr_version
            msg = 'old'
          end
        end
      rescue => e
        log_error e
        msg = "Error: " + e.to_s
      end
    end
    respond_to do |format|
      format.html { redirect_to optional_matrix_resource_url(:controller => :characters, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id =>  @character.id ) }
      format.json { render :json => {:msg => msg}}
    end
  end

  def delete_selected
    super current_project.characters
  end

  def send_email
    flash[:notice] = 'Email Sent!'
    Postoffice.deliver_welcome('test', params[:email][:body])
    respond_to do |format|
      format.html { redirect_to project_character_path(params[:project_id], params[:id]) }
      format.xml  { head :ok }
      format.js
    end
  end

  private
  def fill_characters_list_attributes_for_index_listing
    @attributes_to_show = [ :name, :short_name, :chr_groups, :creator ]
    @attribute_display_properties = {
      :name         => {
        :link_type => 'href',
        :link => "project_character_path(#{current_project.id}, object)"
      },
      :short_name  => { },
      :creator => { :label => 'Owner', :display_attribute => 'label' },
      :chr_groups => { :label =>  'Character Groups', :display_attribute => 'name', :link => { :project_id => current_project.id, :action => 'show', :controller => :chr_groups }}
    }
  end

  #this could be made more generic if used at more places but for now it seems to be at a good place
  def js_for_selected_characters_check
    function ="function(element){"
    function << "if($('item_select_'+element.value) != null){"
    function << "$('item_select_'+element.value).checked = true;"
    function << "add_selected_class($('list_item_'+element.value));"
    function << "}" #end if
    function << "}" #end of function

    script = "var sel_list_items = $('sel_list').select('input[name=\"sel_items[]\"]');"
    script << "if(sel_list_items.size() > 0){"
    script << "sel_list_items.each( #{function} );"
    script << "}"
  end


  def create_changeset(old_chr_version, new_chr_version, params_matrix_id)
    matrix_address = ::Matrix::Address.from_s(params_matrix_id)
    changeset = ::Matrix::Changeset.find_or_create_for(current_user, matrix_address)
    changeset.modify_x_item(old_chr_version, new_chr_version)
  end
end
