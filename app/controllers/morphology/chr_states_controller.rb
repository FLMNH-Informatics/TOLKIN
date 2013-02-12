class Morphology::ChrStatesController < ApplicationController

  before_filter :requires_selected_project
  before_filter :requires_project_guest, :only => [ :index, :show ]
  before_filter :requires_project_updater, :only => [ :new, :edit, :create, :update ]
  before_filter :requires_project_manager, :only => [ :destroy ]

  before_filter :get_chr_state, :only => [:show, :edit, :update, :destroy, :citation_add, :delete_citation]
  def index
    @chr_states = Morphology::ChrState.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @chr_states }
    end
  end

  def show
    respond_to do |format|
      format.html {redirect_to project_character_path(params[:project_id], @chr_state.character_id.to_s,:id=>@chr_state.character_id)}
      format.xml  { render :xml => @chr_state }
    end
  end


  def new
    @chr_state = Morphology::ChrState.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @chr_state }
      format.js
    end
  end

  def show_add_citation
    @chr_state = Morphology::ChrState.find(params[:id])
    respond_to do |format|
      format.html { render 'show_add_citation', layout: request.xhr? ? false : true }
    end
  end

  def show_add_image
    @character = Morphology::Character.find(params[:character_id])
    @chr_state = Morphology::ChrState.find(params[:id])
    respond_to do |format|
      format.html { render 'show_add_image', layout: request.xhr? ? false : true }
    end
  end

  def attach_image
    old_chr_version = current_project.characters.find(params[:character_id])
    file = {}
    file[:attachment] = params[:chr_state_image_file]
    msg = nil
    @chr_state = old_chr_version.chr_states.find(params[:id])
    unless file[:attachment].nil?
      begin
        Morphology::ChrState.transaction do
          @image = Image.create(file.merge({:created_by => current_user.user_id}))
          if old_chr_version.is_current
            new_chr_version = old_chr_version.create_clone
            new_chr_state = new_chr_version.chr_states.find_by_name_and_state(@chr_state.name, @chr_state.state)
            new_chr_state.images << @image
            @character = new_chr_version
            msg = @character.id
            flash[:notice] = "Image attached."
          else
            if params[:matrix_id]
              @chr_state.images << @image
              @character = old_chr_version
            else
              msg = "You can only add images to the most recent version or the versions attached to matrices"
              flash[:notice] = msg unless request.xhr?
            end
          end
        end
        html = msg.nil? ? render_to_string(:partial => 'morphology/characters/character_state.html.haml', :locals => {:state => @chr_state }) : msg
      rescue => e
        log_error e
        html = "Error: " + e.to_s
      end
      respond_to {|format| format.html {render :text => html}}
    end
  end

  def remove_image
    begin
      old_chr_version = current_project.characters.find(params[:character_id])
      @chr_state = old_chr_version.chr_states.find(params[:id])
      msg = "old"
      @chr_state.transaction do
        if old_chr_version.is_current
          new_chr_version = old_chr_version.create_clone
          new_chr_state = new_chr_version.chr_states.find_by_name_and_state(@chr_state.name, @chr_state.state)
          new_chr_state.images = (new_chr_state.images - [Image.find(params[:image_id])])
          @character = new_chr_version
          msg = new_chr_version.id.to_s
          flash["notice"] = "Image successfully removed"
        else
          if params[:matrix_id]
            @chr_state.images = (@chr_state.images - [Image.find(params[:image_id])])
            old_chr_version.save
            @character = old_chr_version
          else
            msg = "You can only remove images from recent versions or versions attached to matrices."
            flash["notice"] = msg unless request.xhr?
          end
        end
      end
    rescue => e
      log_error e
      msg = "Error: " + e.to_s
    end
    respond_to do |format|
      format.json { render :json => {:msg => msg}}
    end
  end

  def citation_add
    msg = 'ok'
    partial = ''
    Morphology::ChrState.transaction do
      begin
        old_chr_version = current_project.characters.find(params[:character_id])
        cit_ids = params[:citation_ids] - @chr_state.citations.map{|citation| citation.id.to_s } if params[:citation_ids]
        if old_chr_version.is_current
          new_chr_version = old_chr_version.create_clone
          new_chr_state = new_chr_version.chr_states.find_by_name_and_state(@chr_state.name, @chr_state.state)
          cit_ids.each{|id| new_chr_state.citations << Library::Citation.find(id)}
          flash[:notice] = "Citation added"
          msg = new_chr_version.id.to_s
        else
          unless params[:matrix_id].nil?
            cit_ids.each{|id| @chr_state.citations << Library::Citation.find(id)}
            msg = 'old'
            partial = render_to_string(:partial => 'morphology/characters/character_state.html.haml', :locals => {:state => @chr_state })
          else
            msg = "You can only add citations to most recent versions and versions attached to matrices."
            flash[:notice] = msg unless request.xhr?
          end
        end
      rescue => e
        log_error e
        msg = "Error: " + e.to_s
      end
      respond_to{|format| format.json { render :json => {:msg => msg, :partial => partial} } }
    end
  end

  def remove_citation
    old_chr_version = current_project.characters.find(params[:character_id])
    msg = "ok"
    Morphology::ChrState.transaction do
      begin
        @chr_state = Morphology::ChrState.find(params[:id])
        if old_chr_version.is_current
          new_chr_version = old_chr_version.create_clone
          new_chr_state = new_chr_version.chr_states.find_by_name_and_state(@chr_state.name, @chr_state.state)
          new_chr_state.citations = (new_chr_state.citations - [new_chr_state.citations.find(params[:citation_id])])
          flash[:notice] = "Citation removed"
          msg = new_chr_version.id.to_s
          @character = new_chr_version
        else
          unless params[:matrix_id].nil?
            @chr_state.citations = (@chr_state.citations - [@chr_state.citations.find(params[:citation_id])])
            msg = "old"
          else
            msg = "You can only remove citations from most recent version or versions attached to matrices."
            flash[:notice] = msg unless request.xhr?
          end
        end
      rescue => e
        log_error e
        msg = "Error: " + e.to_s
      end
    end
    respond_to do |format|
      format.json { render :json => {:msg => msg}}
    end
  end


  def edit
    respond_to do |format|
      format.html { render 'edit', layout: request.xhr? ? false : true }
      format.xml  { render :xml => @chr_state }
      format.js
    end
  end

  def create
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
        format.html { render :action => "new" }
        format.xml  { render :xml => @chr_group.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    msg = 'ok'
    Morphology::ChrState.transaction do
      begin
        attribute_values = params[:morphology_chr_state]
        attribute_values[:updator_id] = current_user.id
        if @chr_state.character.is_current
          new_chr_version = @chr_state.character.create_clone
          chr_state_new = new_chr_version.chr_states.find_by_name_and_state(@chr_state.name, @chr_state.state)
          chr_state_new.update_attributes!(attribute_values)
          @chr_state = chr_state_new
          msg = "new"
          flash["notice"] = "Character state updated."
        else
          @chr_state.update_attributes!(attribute_values)
        end
      rescue => e
        log_error e
        msg = e.to_s
      end
      response_hash = {}
      response_hash["msg"] = msg
      response_hash["partial"] = render_to_string(:partial => "/morphology/characters/character_state.html.haml", :locals => {:state => @chr_state})
      response_hash["character_id"] = @chr_state.character.id.to_s
      respond_to do |format|
        format.html { redirect_to optional_matrix_resource_url(:controller => :characters, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id => new_chr_version.id) }
        format.xml  { head :ok }
        format.js
        format.json { render :json => response_hash}
      end
    end
  end

  def destroy
    chr_success = true
    begin
      @chr_state.transaction do
        @new_chr_version = @chr_state.character.create_clone
        @new_chr_version.chr_states.find_by_name_and_state(@chr_state.name, @chr_state.state).destroy
        if params[:matrix_id]
          matrix_address = ::Matrix::Address.from_s(params[:matrix_id])
          changeset = ::Matrix::Changeset.find_or_create_for(current_user, matrix_address)
          changeset.modify_x_item(@chr_state.character, @new_chr_version)
        end
      end
    rescue
      chr_success = false
    end
    if chr_success
      flash[:notice] = 'Character State deleted'
    else
      flash[:notice] = 'Error deleting character states'
    end
    respond_to do |format|
      format.html { redirect_to optional_matrix_resource_url(:controller => :characters, :action => :show, :project_id => params[:project_id], :matrix_id => params[:matrix_id], :id => chr_success ? @new_chr_version.id : @chr_state.character.id) }
      format.xml  { head :ok }
      format.js
    end
  end

  def delete_citation
    @chr_state.citations.delete(Library::Citation.find(params[:cit_id]))
    flash[:notice] = "Citation removed successfully."
    respond_to do |format|
      format.js
    end
  end

  def add_chr_state_image
    respond_to do |format|
      format.js
    end
  end

  private
  def get_chr_state
    @chr_state = Morphology::ChrState.find(params[:id])
  end
end
