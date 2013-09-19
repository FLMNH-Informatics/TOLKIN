class Molecular::DnaSamplesController < ApplicationController
  # index, show, new, edit, create, update, destroy, create_state, send_email
  before_filter :params_to_hash
  before_filter :requires_project_guest,   :only => [ :index, :show ]
  before_filter :requires_project_updater, :except => [ :index, :show ]
  before_filter :requires_selected_project

  include Restful::Responder
  include TolkinExporter
  include BulkUploader


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
    Molecular::DnaSample
  end

  def destroy_all
    parser = Restful::Parser.new
    current_project.dna_samples.where(parser.parse(params, :conditions)).destroy_all
    head :ok
  end
  
  def index
    query_params_provided? ||
      params.merge!(
        joins: :taxon,
        include: {
          taxon: { select: :label },
          collection: { select: :label }
        },
        order: { taxa: :name },
        limit: 20
      )
    super(current_project.dna_samples)
  end

  def new
    @dna_sample = Molecular::DnaSample.new()
    @attributes = get_attributes
    path = project_molecular_dna_samples_path
    respond_to do |format|
      format.html { render :new , :layout => request.xhr? ? false : 'application'  }
      format.js   { render :partial => 'dna_details', :locals => { :container_id => 'dna_sample_details_window', :path => path } }
      format.json { render :json => @dna_sample }
      format.xml  { render :xml => @dna_sample }
    end
  end

  def show
 
    query_params_provided? ||
      params.merge!({
        include: {
          taxon: {
            select: [
              'taxon_id',
              'namestatus_id',
              'name',
              'author',
              'infra_author',
              'publication',
              'volume_num',
              'pages',
              'publication_date' ],
            include: :namestatus
          },
          collection: {
            select: [ 'id', 'collector', 'collection_number' ]

          }
        }
      })
    super current_project.dna_samples

    
#    @dna_sample = @current_project.dna_samples.find(params[:id], include: [{ taxon: :namestatus }, :collection, :taxa ],
#      select: [ 'dna_samples.*',
#                'taxonomies.name',
#                'taxonomies.author',
#                'taxonomies.infra_author',
#                'taxonomies.publication',
#                'taxonomies.volume_num',
#                'taxonomies.pages',
#                'taxonomies.publication_date',
#                'namestatuses.status',
#                'collections.collector',
#                'collections.collection_number'
#              ].join(','))
#    path = project_molecular_dna_sample_path
#    respond_to do |format|
#      format.html
#      format.js   { render :partial => 'dna_details', :locals => { :container_id => 'dna_sample_details_window', :path => path } }
#      format.xml  { render :xml => @dna_sample }
#    end
  end


  def show_no_edit
    @project = Project.find(params[:project_id])
    @dna_sample = Molecular::DnaSample.find(params[:id])
    @can_edit = @dna_sample.can_edit?(session[:user_id])
    @attributes = get_attributes
    @update_url = project_molecular_dna_sample_path(params[:project_id], @dna_sample)
    respond_to do |format|
      format.js
      format.html
      format.xml  { render :xml => @dna_sample }
    end
  end

  def edit
    @project = Project.find(params[:project_id])
    @dna_sample = Molecular::DnaSample.find(params[:id])
    @attributes = get_attributes
  end

  def create
    params[:dna_sample].update(params.delete(:molecular_dna_sample)) if params.has_key?(:molecular_dna_sample)
    
    params[controller_name.singularize.to_sym].each do |(k,v)|
      params[controller_name.singularize.to_sym][k] = [*v].first
    end
    start_vals = params[controller_name.singularize.to_sym]
    namespace = self.class.to_s.split('::')[0..-2].join('::')
    model_name = controller_name.singularize.camelize
    model = [namespace, model_name].join('::').constantize
    start_vals = process_update_fields(start_vals, model)

#    @attributes_to_show = [ :id, :taxon, :creator ]
#    @attribute_display_properties = {
#      :id => { :label => 'ID',
#      :link_type => 'js',
#      :link_function => "new Ajax.Request('?', {asynchronous:true, evalScripts:true, method: 'get'});return false;",
#        :link_params => 'project_molecular_dna_sample_path(params[:project_id], object.id)'},
#      :taxon => { :label => 'Species name',
#        :display_attribute => 'name' },
#      :creator => { :label => 'Added by',
#        :display_attribute => ['first_name', 'last_name'] }
#    }
#    @project = Project.include().find(params[:project_id])
    @dna_sample = Molecular::DnaSample.new(start_vals)
    @dna_sample.project_id = current_project.id
#      Project.find(params[:project_id])
    @dna_sample.creator_id = current_user.id #session[:user_id]

    respond_to do |format|
      if @dna_sample.save
        
        flash[:notice] = 'DNA Sample was successfully created.'
        format.html { redirect_to(    path = project_molecular_dna_samples_path(@project)) }
        format.xml  { render :xml => @dna_sample, :status => :created, :location => @dna_sample }
        format.json { render :json => @dna_sample}
        #format.js   { render json: 'shared/create' }

      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dna_sample.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    #hack to fix rails3 name spacing splitting for special helpers
    params[:dna_sample].update(params.delete(:molecular_dna_sample)) if params.has_key?(:molecular_dna_sample)

    respond_to_update_request#(@current_project.dna_samples)
  end

  def destroy

    @dna_sample = Molecular::DnaSample.find(params[:id])
    is_destroyed = @dna_sample.destroy

    if is_destroyed
      flash[:notice] = 'DNA Sample Deleted'
    else
      flash[:notice] = 'Error Deleting DNA Sample'
    end

    respond_to do |format|
      format.html { redirect_to     path = project_molecular_dna_samples_path(params[:project_id]) }
      format.xml  { head :ok }
    end
  end

  def delete_selected
    #FIXME without the appropriate foreign key actions set I can leave orphans in the database
    #todo: investigate above
    super current_project.dna_samples
  end

  def display_dna_samples_column_names
     @array_col = []
      @dna_col = Molecular::DnaSample.column_names
      @dna_col.each do |col_name|
        if col_name.gsub!('_id','')
            @array_col.push(col_name.gsub('_id','')+'_label')
        else
          @array_col.push(col_name)
        end
      end
      @table_col = @array_col
      render :partial => "shared/list_of_table_columnnames" , :locals => {:controller_name => "molecular/dna_samples"}
   end

  private

  def get_attributes
    @@attributes ||= [ { :name => :taxon_id        , :label => "Taxon ID", :edit_type => :autocomplete },
      { :name => :collection_id      , :label => "Collection ID", :edit_type => :collection, :enum_object => Recpermission, :enum_name_column => 'name' },
      { :name => :sample_nr          , :label => "Sample NR", :edit_type => 'standard' },
      { :name => :sample_type        , :label => "Sample Type", :edit_type => 'standard' },
      { :name => :amount             , :label => "Amount", :edit_type => 'standard' },
      { :name => :deposited          , :label => "Deposited", :edit_type => 'standard' },
      { :name => :date_received      , :label => "Date Received", :edit_type => 'standard' },
      { :name => :date_extracted     , :label => "Date Extracted", :edit_type => 'standard' },
      { :name => :extraction_protocol, :label => "Extraction Protocol", :edit_type => 'standard' },
      { :name => :source             , :label => "Source", :edit_type => 'standard' },
      { :name => :private_source     , :label => "Private Source", :edit_type => 'standard' },
      { :name => :team               , :label => "Team", :edit_type => 'standard' },
      { :name => :notes              , :label => "Notes", :edit_type => 'standard' },
      { :name => :loc_freezer        , :label => "Loc Freezer", :edit_type => 'standard' },
      { :name => :loc_shelf_bin      , :label => "Loc Shelf Bin", :edit_type => 'standard' },
      { :name => :loc_rack_bag       , :label => "Loc Rack Bag", :edit_type => 'standard' },
      { :name => :loc_box            , :label => "Loc Box", :edit_type => 'standard' },
      { :name => :loc_column         , :label => "Loc Column", :edit_type => 'standard' },
      { :name => :loc_row            , :label => "Loc Row", :edit_type => 'standard' },
      { :name => :recpermission      , :label => "Record Permissions", :edit_type => :collection, :enum_object => Recpermission, :enum_name_column => 'name'}]
  end
end
