require 'bio'

class Molecular::MatricesController < ApplicationController
  include Restful::Responder
  include Molecular::MatricesHelper
  before_filter :set_project_variable
  before_filter :requires_project_guest
  before_filter :requires_project_updater, :except => [ :index, :show ]
  before_filter :requires_selected_project

  def create
    Molecular::Matrix.transaction do
      @matrix = Molecular::Matrix.create!(:name => params[:name])
      @timeline = Molecular::Matrix::Timeline.create!(:description => params[:description],
                                                      :matrix_id => @matrix.id)
    end
    respond_to{|format|format.json{render :json => {:id => @timeline.id}}}
  end

  def edit
    get_objs
    @matrix = @timeline.matrix
    respond_to{|format| format.html { render 'edit', layout: request.xhr? ? false : 'application' } }
  end

  def update_info
    @timeline = Molecular::Matrix::Timeline.find(params[:id])
    @timeline.matrix.name = params[:name]
    @timeline.description = params[:description]
    @timeline.save!
    @timeline.matrix.save!
    respond_to{|format| format.json { render json: {:html => render_to_string('_matrix_title.html.haml') } } }
  end

  def index
    query_params_provided? ||
      params.merge!(
        select: [:*],
        limit: 20
        )
    super current_project.molecular_matrix_views
  end

  def new
    super current_project.molecular_matrices
  end

  def create_next_version
    timeline = Molecular::Matrix::Timeline.find(params[:id])
    @timeline = timeline.create_next_version
    @matrix = timeline.matrix
    respond_to{|format|format.json{ render :json => {:id => @timeline.id, :name => @matrix.name, :description => @timeline.description}}}
  end

  def show_create_next_version
    @timeline = Molecular::Matrix::Timeline.find(params[:id])
    respond_to{|format| format.html { render 'edit', layout: request.xhr? ? false : 'application' } }
  end

  def show_next_version
    timeline = Molecular::Matrix::Timeline.find(params[:id])
    @timeline = timeline.create_next_version
    @matrix = @timeline.matrix
    respond_to{|format| format.html { render 'edit', layout: request.xhr? ? false : 'application' } }
  end

  def show_view_by_date
    @timeline = Molecular::Matrix::Timeline.find(params[:id])
    respond_to do |format|
      format.html { render 'show_view_by_date', layout: request.xhr? ? false : 'application' }
    end
  end

  def get_times_for_date
    start_time = params[:date] + '000000'
    end_time   = params[:date] + '235959'
    datetimes = []
    ["Cell", "MatricesMarkers", "MatricesOtus"].each do |obj|
      ( (obj == "Cell" ? "Molecular::Matrix::" : "Molecular::Matrix::") + obj ).constantize.where('timeline_id = ? and create_date <= ? and create_date >= ?', params[:id], end_time.to_datetime, start_time.to_datetime).each{|item| datetimes << item.create_date}
    end
    respond_to do |format|
      format.json { render :json => { :times => datetimes.uniq.sort.inject([]){|memo, time| memo.push([time.strftime("%T"), time.to_s(:number)])}.to_json}}
    end
  end

  def view_by_date
    date = params[:date].to_datetime.utc
    @timeline = Molecular::Matrix::Timeline.find(params[:id])
    @matrices_markers = Molecular::Matrix::MatricesMarkers.includes(:marker).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', params[:id], date, date).order('position')
    @markers = @matrices_markers.map{|mm|mm.marker}
    @matrices_otus    = Molecular::Matrix::MatricesOtus.includes(:otu).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', params[:id], date, date).order('position')
    respond_to do |format|
      format.html { render 'view_by_date', layout: request.xhr? ? false : true }
      format.json { render json: {:info => {:timeline => @timeline, :matrix => @timeline.matrix, :versions => @timeline.matrix.timelines, :matrices_otus => @matrices_otus }}}
    end
  end

  def load_row
    date = ( params["date"] || Time.now ).to_datetime.utc
    @motu = Molecular::Matrix::MatricesOtus.find(params['matrix_otu_id'])
    marker_ids = params[:y_ids]
    @cells_array = marker_ids.collect do |marker_id|
      [Molecular::Matrix::Cell.where('timeline_id = ? and otu_id = ? and marker_id = ? and create_date <= ? and (overwrite_date >= ? or overwrite_date IS NULL)', params[:id], params[:otu_id], marker_id, date, date).first, params[:otu_id], marker_id]
    end if marker_ids
    respond_to{|format|format.json{render json: {:row => row_builder(@motu)}}}
  end

  def show
    if params[:sort_both] and params[:sort_both] == "true"
      params[:sort_markers] = true
      params[:sort_otus]    = true
    end
    @timeline = Molecular::Matrix::Timeline.includes(:markers).find(params[:id])
    timeline_id = params[:id]
    if params[:sort_markers].nil?
      @markers = @timeline.markers.paginate(:page => params[:page], :per_page => 15, :order => "mol_matrices_markers.position")
      #@markers = @markers.paginate(:page => params[:page], :per_page => 15, :order => "mol_matrices_markers.position")
    else
      date = DateTime.now.utc
      marker_sql = %(
        SELECT mm.*, coalesce(mc_count.cells_count,0) as cells_count, coalesce(mc_seq_count.seq_count,0) as seq_count
        FROM mol_matrices_markers mm
            LEFT OUTER JOIN
              (
                SELECT marker_id, count(marker_id) as cells_count
                FROM mol_matrix_cells
                WHERE timeline_id = #{timeline_id} and is_active = true
                GROUP BY marker_id
              ) as mc_count
            ON mm.marker_id = mc_count.marker_id
            LEFT OUTER JOIN
              (
                SELECT marker_id, sum(sequence_count) as seq_count
                FROM mol_matrix_cells
                WHERE timeline_id = 24 and is_active = true
                GROUP BY marker_id
              ) as mc_seq_count
            ON mm.marker_id = mc_seq_count.marker_id
        WHERE mm.timeline_id = #{timeline_id}
        ORDER BY cells_count DESC NULLS LAST, seq_count DESC NULLS LAST, mm.position
      )
      @matrices_markers = Molecular::Matrix::MatricesMarkers.find_by_sql(marker_sql)
      @markers = @matrices_markers.map{ |mm| mm.marker }.paginate( :page => params[:page], :per_page => 15 )
    end
    if params[:sort_otus].nil?
      @matrices_otus = @timeline.matrices_otus
    else
      motu_sql = %(
        SELECT mo.*, COALESCE(mc_count.count, 0) as cells_count, coalesce(mc_seq_count.seq_count, 0) as seq_count
        FROM mol_matrices_otus mo
           LEFT OUTER JOIN
               (
                 SELECT otu_id, count(otu_id) as count
                 FROM mol_matrix_cells
                 WHERE timeline_id = #{timeline_id} and is_active = true
                 GROUP BY otu_id
               ) as mc_count
           ON mo.otu_id = mc_count.otu_id
           LEFT OUTER JOIN
               (
                  SELECT otu_id, sum(sequence_count) as seq_count
                  FROM mol_matrix_cells
                  WHERE timeline_id = #{timeline_id} and is_active = true
                  GROUP BY otu_id
               ) as mc_seq_count
           ON mo.otu_id = mc_seq_count.otu_id
        WHERE mo.timeline_id = #{timeline_id}
        ORDER BY cells_count DESC NULLS LAST, seq_count DESC NULLS LAST, mo.position
      )
      motus = Molecular::Matrix::MatricesOtus.find_by_sql(motu_sql)
      @matrices_otus = motus
    end
    respond_to do |format|
      format.html { render 'show', layout: request.xhr? ? false : true }
      format.json { render json: {:info => {:timeline => @timeline, :matrix => @timeline.matrix, :versions => @timeline.matrix.timelines, :matrices_otus => @matrices_otus }}}
    end
  end

  def show_copy_matrix
    @timeline = Molecular::Matrix::Timeline.find(params[:id])
    respond_to{|format| format.html { render 'edit', layout: request.xhr? ? false : 'application' } }
  end

  def copy_matrix
    date = (params[:date].nil? ? DateTime.now : params[:date].to_datetime).utc
    #TODO timeline functions to get by date
    timeline = Molecular::Matrix::Timeline.find(params[:id])
    @timeline = timeline.copy(date)
    @timeline.update_attributes(:description => (params[:description] + " " + @timeline.description))
    @matrix = @timeline.matrix
    @matrix.update_attributes(:name => params["name"])
    respond_to{|format| format.json { render :json => {:id => @timeline.id, :name => @matrix.name, :description => @timeline.description} } }
  end

  def modify_matrix
    get_objs
  end

  def change_position
    begin
      obj_type = "Molecular::Matrix::" + "Matrices" + params[:type].capitalize.pluralize
      @object = obj_type.constantize.where("timeline_id = ? and " + params[:type] + "_id = ?", params[:id], params[params[:type]+ "_id"]).first
      unless @object.nil?
        obj_type.constantize.transaction do
          @object.try(params[:move])
        end
      else
        respond_to{|format| format.json { render json: {:error => 'Sorry, something went wrong.  ' } } }
      end
    rescue RuntimeError => e
      debugger
    rescue => e
      debugger
    end
    get_objs(params[:type])
    respond_to{|format| format.json { render json: {:type => params[:type], :html => render_to_string('_modify_matrix_' + params[:type].pluralize + '.html.erb') } } }
  end

  def bulk_sequence_exporter
    date = (params[:date].nil? ? DateTime.now : params[:date].to_datetime).utc
    @project = current_project
    get_objs_by_date(date)
  end

  def delete_selected
    super current_project.molecular_matrix_timelines
  end

  def show_autofill_matrix
    respond_to { |format| format.html { render 'show_autofill_matrix', layout: request.xhr? ? false : 'application'} }
  end

  def autofill_matrix
    timeline = Molecular::Matrix::Timeline.find(params[:id])
    timeline.autofill(params[:status])
    head :ok
  end

  def show_add_marker
    @marker = Molecular::Marker.new
    @timeline = Molecular::Matrix::Timeline.find(params[:id])
    respond_to do |format|
      format.html { render 'show_add_marker', layout: request.xhr? ? false : 'application' }
    end
  end

  def show_add_otu
    @otu = Otu.new
    respond_to do |format|
      format.html { render 'show_add_otu', layout: request.xhr? ? false : 'application' }
    end
  end

  def update_otu
    @timeline  = Molecular::Matrix::Timeline.find(params[:id])
    begin
      Otu.transaction do
        raise 'neither an OTU nor an OTU group has been selected' if params[:otu][:name].blank? and params[:otu_group_id].blank?
        otus_to_add = params[:otu][:name].blank? ? current_project.otu_groups.find(params[:otu_group_id]).otus : [ current_project.otus.active.find_by_name(params[:otu][:name]) ]
        fail("otus to add not found") if otus_to_add.compact.empty?
        #otus_to_add.each{ |otu| @timeline.otus << otu unless @timeline.matrices_otus.in_list.map{|mo|mo.otu}.include?(otu) }
        @timeline.otus = @timeline.otus | otus_to_add #otus_to_add.each{ |otu| @timeline.otus << otu unless @timeline.matrices_otus.in_list.map{|mo|mo.otu}.include?(otu) }
      end
      @timeline.reload
      @matrices_otus = @timeline.matrices_otus
      flash[:notice] = "OTU(s) successfully added." unless request.xhr?
    rescue ActiveRecord::RecordNotSaved => e
      flash[:error] = "Error adding OTU(s): #{e.message} " unless request.xhr?
    rescue RuntimeError => e
      flash[:error] = "Error adding OTU(s): #{e.message} " unless request.xhr?
    rescue => e
      log_error e
      flash[:error] = "Error adding OTU(s): #{e.message}" unless request.xhr?
    end
    if e
      respond_to{|format| format.json { render :json => {:message => e.message}.to_json } }
    else
      respond_to do |format|
        format.xml  { head :ok }
        format.js   { head :ok }
        format.json { render :json => { :otu_list => render_to_string(:partial => "modify_matrix_otus.html.erb")}}
      end
    end
  end

  def update_marker
    @timeline  = Molecular::Matrix::Timeline.find(params[:id])
    begin
      names = []
      names = names | params[:marker_names] unless params[:marker_names].blank?
      names.push(params[:new_marker]) unless params[:new_marker].blank?
      current_names = @timeline.matrices_markers.in_list.collect{|mm| mm.marker.name }.compact
      names.each{|marker_name| @timeline.markers << current_project.markers.find_or_create_by_name(marker_name) unless current_names.include?(marker_name) }
      @timeline.reload
      @matrices_markers = @timeline.matrices_markers.in_list
      flash[:notice] = "Marker(s) successfully added." unless request.xhr?
    rescue ActiveRecord::RecordNotSaved => e
      flash[:error] = "Error adding marker(s): #{e.message} " unless request.xhr?
    rescue RuntimeError => e
      flash[:error] = "Error adding marker(s): #{e.message} " unless request.xhr?
    rescue => e
      log_error e
      flash[:error] = "Error adding marker(s): #{e.message}" unless request.xhr?
    end
    if e
      respond_to{|format| format.json { render :json => {:message => e.message}.to_json } }
    else
      respond_to do |format|
        #format.html { redirect_to(modify_matrix_project_molecular_matrix_path(params[:project_id], @matrix)) }
        format.html { render :partial => "modify_matrix_markers.html.erb" }
        format.xml  { head :ok }
        format.js   { head :ok }
        format.json { render :json => {:marker_list => render_to_string(:partial => "modify_matrix_markers.html.erb")} }
      end
    end
  end

  def remove_marker
    @timeline = Molecular::Matrix::Timeline.find(params[:id])
    markers = *Molecular::Marker.find(params[:marker_id])
    markers.each{|m|@timeline.remove_marker(m)}
    get_objs
    respond_to do |format|
      format.html{redirect_to(modify_matrix_project_molecular_matrix_path(params[:project_id],@timeline))}
      format.json{render :json => {:list => render_to_string(:partial => "modify_matrix_markers.html.erb")}}
    end
  end

  def remove_otu
    @timeline = Molecular::Matrix::Timeline.find(params[:id])
    otus = *Otu.find(params[:otu_id])
    otus.each{|o|@timeline.remove_otu(o)}
    get_objs
    respond_to do |format|
      format.js { head :ok}
      format.html { redirect_to (modify_matrix_project_molecular_matrix_path(params[:project_id], @timeline)) }
      format.json{render :json => {:list => render_to_string(:partial => "modify_matrix_otus.html.erb")}}
    end
  end

  def set_project_variable
    @project = current_project
  end

  private
  def get_objs(object_type = 'all')
    @project          = current_project
    @timeline         = Molecular::Matrix::Timeline.includes(:matrix).find(params[:id])
    #@matrices_otus   = @timeline.matrices_otus.includes(:otu)          unless object_type == "marker"
    @matrices_otus    = Molecular::Matrix::MatricesOtus.includes(:otu).where('timeline_id = ? and (delete_date is null)', params[:id]).order('position')  unless object_type == "marker"
    @matrices_markers = Molecular::Matrix::MatricesMarkers.includes(:marker).where('timeline_id = ? and delete_date is null', params[:id]).order('position') unless object_type == "otu"
    #@matrices_markers = @timeline.matrices_markers.includes(:marker)    unless object_type == "otu"
  end

  def get_objs_by_date(date = DateTime.now())
    date = date.utc
    @matrices_markers = Molecular::Matrix::MatricesMarkers.includes(:marker).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', params[:id], date, date).order('position')
    @matrices_otus    = Molecular::Matrix::MatricesOtus.includes(:otu).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', params[:id], date, date).order('position')
    @timeline = Molecular::Matrix::Timeline.find(params[:id])
    @cells = Molecular::Matrix::Cell.find_by_timeline_and_date(@timeline, date)
    @markers = @matrices_markers.map{|mmarker|mmarker.marker}
    @otus = @matrices_otus.map{|motu|motu.otu}
  end
end