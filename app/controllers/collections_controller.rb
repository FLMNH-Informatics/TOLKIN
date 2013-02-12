require 'restful/responder'

class CollectionsController < ApplicationController

  include Restful::Responder
  
  before_filter :params_to_hash
  before_filter :requires_selected_project
  before_filter :requires_project_guest, :only => [ :list, :show ]
  before_filter :requires_project_updater, :only => [ :new, :create, :edit, :update, :update_collection, :update_others ]
  before_filter :requires_project_manager, :only => [ :destroy, :delete_selected ]
  #check if the project param is available in the url
  skip_before_filter :requires_any_guest, :only => [ :index]

  before_filter :check_record_permission, :except=> [:index, :list, :update, :new, :create, :show, :delete_selected , :display_collection_column_names]

  #  Collection.content_columns.each do |column|
  #    in_place_edit_for :collection, column.name
  #  end



  auto_complete_for :collection, :collection_number, :project_scope => true

  def resource
    Collection
  end

  def index
    #TODO: rss still not properly allowed
    #FIXME: letting through all xhr and rss requests for now - needed for public taxa pages, not ideal
    if current_user != User.public_user || request.xhr? || request.format.rss?
      query_params_provided? ||
        params.merge!(
        select: [ :id, :collector, :collection_number, :taxon_id, :country, :island, :state_province, :locality, :coll_start_date, :calc_lat_dd, :calc_long_dd ],
        joins: :taxon.outer,
        include: {
          taxon: { select: [ :taxon_id, :label ] }
        },
        order: [ { :taxa => :name }, :country, :collector, :collection_number ],
        limit: 20
      )
      super(
        (params[:taxon_id] ? Collection.where(taxon_id: params[:taxon_id]) : Collection).
          where(project_id: @current_project.id)
      )
    else
      permission_denied
    end
  end

  def show
    query_params_provided? ||
      params.merge!(
      include: {
        taxon: {
          select: [ 'taxon_id', 'label', 'namestatus_id' ],
          include: :namestatus
        },
        annotations: { select: '*' },
        creator: {
          select: ['user_id', 'full_name']
        },
        updater: {
          select: ['user_id', 'full_name']
        },
        elevation_unit: { select: '*'},
        images: { select: '*' }
      }
    )
    super current_project.collections
  end

  def new
    @collection = Collection.includes(:taxon).new
    @annotation = Annotation.new 
    respond_to {|format|
      format.html { render 'new', layout: request.xhr? ? false : true }
    }
  end

  def search
    
  end

  def create_copy
    @collection = current_project.collections.includes(:taxon).new(current_project.collections.find(params[:id]).attributes)
    #   @collection = Collection.create_copy(params[:id])
    respond_to {|format|
      format.html { render 'new', layout: request.xhr? ? false : true }
      #format.js { render 'new.html.erb', layout: request.xhr? ? false : true }
    }
  end

  def create
    params[:collection][:iso_country_code] = params[:country][:id]
    params[:collection].each do |(k,v)|
      params[:collection][k] = [*v].first
    end
    #lat/long degress trigger protect
    #    if(params[:collection][:long_dd].strip == '' || params[:collection][:long_dd].nil? )
    #      params[:collection].delete('longitude')
    #    end
    #
    #    if(params[:collection][:latitude].strip == '' || params[:collection][:latitude].nil? )
    #      params[:collection].delete('latitude')
    #    end
    # Handle locality format and calculate decimal locality
    case params[:collection][:lat_long_rep]
      when 'DMS'
        params[:collection][:lat_dd] = ''
        params[:collection][:long_dd] = ''
        params[:collection][:calc_lat_dd] = calculate_dd 'lat' if !params[:collection][:lat_deg].blank?
        params[:collection][:calc_long_dd] = calculate_dd 'long' if !params[:collection][:long_deg].blank?

      when 'DD'
        ['lat_deg','lat_min','lat_sec','long_deg','long_min','long_sec'].each{|d| params[:collection][d] = ''}
        params[:collection][:calc_lat_dd] = params[:collection][:lat_dd] if !params[:collection][:lat_dd].blank?
        params[:collection][:calc_long_dd] = params[:collection][:long_dd] if !params[:collection][:long_dd].blank?
    end
    
    @collection = Collection.new(params[:collection])
    @collection.transaction do
      if(params[:collection][:accuracy]=="other" && !params[:collection_aux_accuracy].nil? &&params[:collection_aux_accuracy].strip!="")
        @collection.accuracy=params[:collection_aux_accuracy]
      elsif params[:collection][:accuracy]=="other" && (params[:collection_aux_accuracy].nil? || params[:collection_aux_accuracy].strip =="")
        @collection.accuracy=nil
      end
      @tax=params[:taxon]
      @collection.last_updated_by = @current_user.id;
      @collection.user_id = @current_user.id;
      @collection.project_id = Project.exists?(params[:project_id]) ? params[:project_id] : nil
      @collection.save!
#      i=1
#      while(!params[("annotation"+i.to_s).to_sym].nil?)
#        @annotation = Annotation.new(params[("annotation"+i.to_s).to_sym])
#        if ((@annotation.taxon.to_s.strip!="" || !@annotation.taxon.to_s.nil?) &&  (@annotation.name.to_s.strip!="" || !@annotation.name.to_s.nil?) && (@annotation.date.to_s.strip!="" || !@annotation.date.to_s.nil?) && (@annotation.inst.to_s.strip!="" || !@annotation.inst.to_s.nil?) )
#          @annotation.collection_id=@collection.id
#          @annotation.save!
#        end
#        i=i+1
#      end
     
      annotations_add = params.delete(:annotations_add)
      annotations_add.each do |key,val|
        Annotation.create({:collection_id => @collection.id, :taxon => val[:taxon], :name => val[:name], :date => val[:date], :inst => val[:institution] })
      end if annotations_add

    end
    respond_to do |format|
      format.html { head :ok }
      format.json { render json: { id: @collection.id } }
    end
  end

  def edit
    @collection = Collection.find(params[:id])
    @annotations=Annotation.find_all_by_collection_id(@collection.id)
  end

  def calculate_dd(lat_or_long)
    calc = params[:collection]["#{lat_or_long}_deg"].to_f + (params[:collection]["#{lat_or_long}_min"].to_f / 60) + (params[:collection]["#{lat_or_long}_sec"].to_f / 3600)

    case lat_or_long
    when 'lat'
      calc = -calc if params[:collection][:lat_dir] == 's'
    when 'long'
      calc = -calc if params[:collection][:long_dir] == 'w'
    end
    return calc
  end

  def update

    params.delete(:annotations_inputs)
    annotations_add = params.delete(:annotations_add)
    annotations_del = params.delete(:annotations_del)
    params[:collection][:iso_country_code] = params.delete(:country)[:id]
    params[:collection].each do |(k,v)|
      params[:collection][k] = [*v].first
    end
    # APPROPRIATELY HANDLE FRUITING FLOWERING AND SILICA SAMPLE FIELDS
    fields = params[:collection]
    fields = Collection.columns.inject(fields) do |flds, column|
      case column.type
      when :date    then process_date_attribute(fields, column.name)
      when :boolean then process_boolean_attribute(fields, column.name)
      else fields
      end
    end
    # Handle locality format and calculate decimal locality
    case params[:collection][:lat_long_rep]
    when 'DMS'
      #params[:collection][:lat_dd] = ''
      #params[:collection][:long_dd] = ''
      params[:collection][:calc_lat_dd]  = params[:collection][:lat_deg].blank?  ? nil : calculate_dd('lat')
      params[:collection][:calc_long_dd] = params[:collection][:long_deg].blank? ? nil : calculate_dd('long')

    when 'DD'
      #['lat_deg','lat_min','lat_sec','long_deg','long_min','long_sec'].each{|d| params[:collection][d] = ''}
      params[:collection][:calc_lat_dd]  = params[:collection][:lat_dd].blank?  ? nil : params[:collection][:lat_dd]
      params[:collection][:calc_long_dd] = params[:collection][:long_dd].blank? ? nil : params[:collection][:long_dd]
    end

    #######
    @collection = Collection.find(params[:id])
    if params[:collection].has_key?("accuracy") && params[:collection][:accuracy]=="other" && params[:collection_aux_accuracy]!=""
      params[:collection][:accuracy] = params[:collection_aux_accuracy]
    elsif params[:collection][:accuracy]=="other" && params[:collection_aux_accuracy]==""
      params[:collection][:accuracy] = nil
    end
    #     debugger
    #    params[:collection][:coll_start_date] = params[:collection][:verbatim_coll_start_date_Y]+params[:collection][:verbatim_coll_start_date_M]+params[:collection][:verbatim_coll_start_date_D]
    #    params[:collection][:coll_end_date] = params[:collection][:verbatim_coll_end_date_Y]+params[:collection][:verbatim_coll_end_date_M]+params[:collection][:verbatim_coll_end_date_D]
    #    params[:collection].delete(:verbatim_coll_start_date_Y)
    #    params[:collection].delete(:verbatim_coll_start_date_M)
    #    params[:collection].delete(:verbatim_coll_start_date_D)
    #    params[:collection].delete(:verbatim_coll_end_date_Y)
    #    params[:collection].delete(:verbatim_coll_end_date_M)
    #    params[:collection].delete(:verbatim_coll_end_date_D)
    #    debugger
    # necessary preprocessing right now for combo box
    params[:collection].each do |(k,v)|
      params[:collection][k] = [*v].first
    end
    if @collection.can_edit?(session[:user_id]) && @collection.update_attributes(params[:collection])
      @taxon=params[:taxon]

      annotations_add.each do |key,val|
        Annotation.create({:collection_id => params[:id], :taxon => val[:taxon], :name => val[:name], :date => val[:date], :inst => val[:institution] })
      end if annotations_add

      annotations_del.each do |key,val|
        Annotation.delete(key)
      end if annotations_del 
#      @annotations=Annotation.find_all_by_collection_id(@collection.id)
#      #TODO: absolutely awful - this is super dangerous
#      Annotation.destroy_all "collection_id = " +@collection.id.to_s
#      i=1
#      while(!params[("annotation"+i.to_s).to_sym].nil?)
#        @annotation = Annotation.new(params[("annotation"+i.to_s).to_sym])
#        if ((@annotation.taxon.to_s.strip!="" || !@annotation.taxon.to_s.nil?) &&  (@annotation.name.to_s.strip!="" || !@annotation.name.to_s.nil?) && (@annotation.date.to_s.strip!="" || !@annotation.date.to_s.nil?) && (@annotation.inst.to_s.strip!="" || !@annotation.inst.to_s.nil?) )
#          @annotation.collection_id=@collection.id
#          @annotation.save
#
#        end
#        i=i+1
#      end
      flash[:notice] = 'Collection was successfully updated.'
      respond_to do |format|
        format.html { redirect_to :back }
        format.js { head :ok }
      end
      
    else
      render :action => 'edit'
    end
  end

  

  def destroy
    if session[:permission_denied]
      session[:permission_denied] = true
      @permission_denied = true
    end
    @collection = Collection.find(params[:id])
    @collection.destroy
    respond_to do |format|
      format.js
      format.html do
        flash[:notice] = 'Collection was successfully deleted.'
        redirect_to project_collections_url(params[:project_id])
      end
      format.json
      format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
    end
  end

  #design flaw fix this make it DRY for now used for ajax requests
  def update_collection
    respond_to do |format|

      @collection = Collection.find(params[:id])
      updated_attributes = params[:collection]
      if updated_attributes[:taxon]
        updated_attributes[:taxon_id] = @current_project.taxa.find_by_name(updated_attributes[:taxon]).id
        updated_attributes.delete(:taxon)
      end
      updated_attributes[:updater] = current_user
      if @collection.can_edit?(session[:user_id]) && @collection.update_attributes(updated_attributes)
        format.html #{ redirect_to(@collection) }
        format.json { render :json => @collection.to_json(:include => :taxon) }#, :only => [ :id, :label ]) }  # <---- add this
        format.xml  { head :ok }
      else
        if session[:permission_denied]
          session[:permission_denied] = false
          @permission_denied = true
        end
        format.json { render :json => @collection.errors.full_messages.to_json }
        format.html { render :action => "update_collection.rjs" }
        format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end

  #new update for others
  def update_others
    @id = params[:id];
    @value = params[:value];
    @parameter=params[:parameter]; #column to update
    if(@parameter == "collection_check")
      if(!params[:collection].nil?)
        column_names = params[:collection].keys
        column_names.each do |col|
          Collection.find(@id).update_attribute(col,params[:collection][col]);
        end
      end
    elsif(@parameter == "collection_date")
      Collection.find(@id).update_attribute("coll_start_date",params[:collection]["coll_start_date(1i)"].to_s+"-"+params[:collection]["coll_start_date(2i)"].to_s+"-"+params[:collection]["coll_start_date(3i)"].to_s);
      Collection.find(@id).update_attribute("coll_end_date",params[:collection]["coll_end_date(1i)"].to_s+"-"+params[:collection]["coll_end_date(2i)"].to_s+"-"+params[:collection]["coll_end_date(3i)"].to_s);
    elsif(@parameter == "collection_annotation")
      Annotation.destroy_all "collection_id = " +@id.to_s
      i=1
      while(!params[("annotation"+i.to_s).to_sym].nil?)
        @annotation = Annotation.new(params[("annotation"+i.to_s).to_sym])
        if ((@annotation.taxon.to_s.strip!="" && !@annotation.taxon.to_s.nil?) &&  (@annotation.name.to_s.strip!="" && !@annotation.name.to_s.nil?) && (@annotation.date.to_s.strip!="" && !@annotation.date.to_s.nil?) && (@annotation.inst.to_s.strip!="" && !@annotation.inst.to_s.nil?) )
          @annotation.collection_id=@id
          @annotation.save
        end
        i=i+1
      end
    end
    @collection=Collection.find(@id)
    @collection.last_updated_by = @current_user.id
  end

  def display_collection_column_names
    @array_col = []
    @collection_col = Collection.column_names
    @collection_col.each do |col_name|
      if !col_name.include?('length_unit_id') && !col_name.include?('copied_from_id')
        if col_name.include?('_id')
          #@array_col.push(col_name.gsub('_id','')+'_label')
          @array_col.push(col_name)
        else
          @array_col.push(col_name)
        end
      end
    end
    @table_col = @array_col
    #render :partial => "shared/list_of_table_columnnames" , :locals => {:controller_name => "collections"}
    render :partial => "list_of_collections_columns" , :locals => {:controller_name => "collections"}
  end

  def export_csv

      if params[:select].include?("taxon_id")
        params.merge!(
        #select: [ :taxon_id ],
        joins: :taxon.outer,
        include: {
          taxon: { select: [ :taxon_id, :name ] }
        }
        )

      end
      #respond_to_index_request_searchlogic(Collection)

      @resource = Collection
      #filter_select if request.format.csv?
      validate(params) && parse(params)
      result = resource.scoped.apply_finder_options(prepare(params, :for => :finder))
      instance_variable_set("@#{resource.collection_name}", result)
      debugger
       render csv:  result

  end

  def correct_annotations
    Collection.find(:all).each do |coll|
      coll.annotations.each do |ann|
      end
    end
  end

  def delete_selected
    super current_project.collections
  end

  def collection_list_variables
    @attributes_to_show = [ :collector, :collection_number, :taxon, :country ]
    @attribute_display_properties = {
      :collector         => { :label => 'Collector',
        :link_type => 'js',
        :link_function => "new Ajax.Request('?', {asynchronous:true, evalScripts:true, method: 'get'});return false;",
        :link_params => 'project_collection_path(params[:project_id], object.id)' },
      :country           => { :label => 'Country'},
      :collection_number => { :label => 'Collection Number',
        :link_type => 'js',
        :link_function => "new Ajax.Request('?', {asynchronous:true, evalScripts:true, method: 'get'});return false;",
        :link_params => 'project_collection_path(params[:project_id], object.id)' },
      :taxon          => { :label => 'Taxon',
        :link_type => 'href',
        :link => 'project_taxon_path(object.taxon.project_id, object.taxon.id)',
        :display_attribute => 'name' },
    }
  end

  private

  def _save_annotations
    debugger
    i=1
    while(!params[("annotation"+i.to_s).to_sym].nil?)
      @annotation = Annotation.new(params[("annotation"+i.to_s).to_sym])
      if (
        !(@annotation.taxon.blank? && @annotation.name.blank? && @annotation.date.blank? && @annotation.inst.blank?) &&
        !@collection.annotations.where(
          taxon: @annotation.taxon,
          name: @annotation.name,
          date: @annotation.date,
          inst: @annotation.inst
        ).first
      )
        @annotation.collection_id=@collection.id
        @annotation.save
      end
      i=i+1
    end
  end
end
