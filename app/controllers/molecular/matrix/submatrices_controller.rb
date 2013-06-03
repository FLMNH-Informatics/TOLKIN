class Molecular::Matrix::SubmatricesController < ApplicationController
  include Restful::Responder

  before_filter :requires_project_updater
  before_filter :requires_selected_project

  def new
    @project = current_project
    @timeline = Molecular::Matrix::Timeline.find(params[:matrix_id])
    @matrices_markers = @timeline.matrices_markers.find_by_sql(%(  SELECT mm.*, coalesce(mc_count.cells_count,0) as cells_count, coalesce(mc_seq_count.seq_count,0) as seq_count, mol_markers.name as name
                FROM mol_matrices_markers mm
                    LEFT OUTER JOIN
                      (
                        SELECT marker_id, count(marker_id) as cells_count
                        FROM mol_matrix_cells
                        WHERE timeline_id = #{@timeline.id} and is_active = true
                        GROUP BY marker_id
                      ) as mc_count
                    ON mm.marker_id = mc_count.marker_id
                    LEFT OUTER JOIN
                      (
                        SELECT marker_id, sum(sequence_count) as seq_count
                        FROM mol_matrix_cells
                        WHERE timeline_id = #{@timeline.id} and is_active = true
                        GROUP BY marker_id
                      ) as mc_seq_count
                    ON mm.marker_id = mc_seq_count.marker_id
                    LEFT OUTER JOIN
                        mol_markers
                    ON mol_markers.id = mm.marker_id
                WHERE mm.timeline_id = #{@timeline.id}
                ORDER BY name
          ))
    @matrices_otus = @timeline.matrices_otus.find_by_sql(%(
        SELECT mo.*, COALESCE(mc_count.count, 0) as cells_count, coalesce(mc_seq_count.seq_count, 0) as seq_count, otus.name as name
        FROM mol_matrices_otus mo
           LEFT OUTER JOIN
               (
                 SELECT otu_id, count(otu_id) as count
                 FROM mol_matrix_cells
                 WHERE timeline_id = #{@timeline.id} and is_active = true
                 GROUP BY otu_id
               ) as mc_count
           ON mo.otu_id = mc_count.otu_id
           LEFT OUTER JOIN
               (
                  SELECT otu_id, sum(sequence_count) as seq_count
                  FROM mol_matrix_cells
                  WHERE timeline_id = #{@timeline.id} and is_active = true
                  GROUP BY otu_id
               ) as mc_seq_count
           ON mo.otu_id = mc_seq_count.otu_id
           LEFT OUTER JOIN
               otus on mo.otu_id = otus.id
        WHERE mo.timeline_id = #{@timeline.id}
        ORDER BY name
      ))
    super @timeline.submatrices
  end

  def create
    begin
      empty =  params[:otu_ids].nil? || params[:marker_ids].nil? || params[:otu_ids].empty? || params[:marker_ids].empty?
      unless empty
        @submatrix = Molecular::Matrix::Submatrix.create!(params[:molecular_matrix_submatrix])
        Molecular::Matrix::MatricesMarkers.order(:position).joins(:marker).find(params[:matrix_marker_ids]).each do |matrix_marker|
          @submatrix.markers << matrix_marker.marker
        end
        Molecular::Matrix::MatricesOtus.order(:position).joins(:otu).find(params[:motu_ids]).each do |matrix_otu|
          @submatrix.otus << matrix_otu.otu
        end
        @timeline = Molecular::Matrix::Timeline.find(params[:matrix_id])
        @submatrices = @timeline.submatrices
        respond_to { |format|
          format.html { render :partial => "shared/panes/submatrix_views.html.haml" }
        }
      else
        respond_to {|format| format.json { render json:  {empty: empty} } }
      end
    rescue => e
      respond_to {|format| format.json {render json: {error: e.to_s}}}
    end
  end

  def edit
    @submatrix = Molecular::Matrix::Submatrix.find(params[:id])
    @timeline = @submatrix.timeline
    respond_to do |format|
      format.html { render 'edit', layout: request.xhr? ? false : true }
    end
  end

  def update
    begin
      @submatrix = Molecular::Matrix::Submatrix.find(params[:id])
      success = @submatrix.update_attributes({:name => params[:name]})
      if success
        @submatrix.submatrix_otus.find(params[:otus_to_remove]).each{|smotu| smotu.destroy} if params[:otus_to_remove]
        @submatrix.submatrix_markers.find(params[:markers_to_remove]).each{|smmarker| smmarker.destroy} if params[:markers_to_remove]
        current_project.otus.find(params[:otus]).each{|otu| @submatrix.otus << otu unless @submatrix.otus.include?(otu)} if params[:otus]
        current_project.markers.find(params[:markers]).each{|marker|@submatrix.markers << marker unless @submatrix.markers.include?(marker)} if params[:markers]
        @timeline = Molecular::Matrix::Timeline.find(params[:matrix_id])
        @submatrices = @timeline.submatrices
        respond_to do |format|
          format.html { render :partial => "shared/panes/submatrix_views.html.haml" }
        end
      else
        respond_to{|format|  format.json { render json:  {error: "That name is already in use."}} }
      end
    rescue => e
      debugger
      'test'
    end
  end

  def destroy
    @submatrix = Molecular::Matrix::Submatrix.find(params[:id])
    @submatrix.delete
    head :ok
  end

  def delete_submatrix
    @submatrix = Molecular::Matrix::Submatrix.find(params[:id])
    @submatrix.delete
    head :ok
  end

  def show
    if params[:sort_both] and params[:sort_both] == "true"
      params[:sort_markers] = true
      params[:sort_otus]    = true
    end
    @submatrix = Molecular::Matrix::Submatrix.find(params[:id])
    @timeline = @submatrix.timeline
    @submatrix_markers = (params[:sort_markers] ? Molecular::Matrix::Submatrix::SubmatrixMarkers.sorted_by_cells(@submatrix) : @submatrix.submatrix_markers).paginate( :page => params[:page], :per_page => 15 )
    @markers = (params[:sort_markers] ? @submatrix_markers.collect{|sm|sm.marker} : @submatrix.markers).paginate( :page => params[:page], :per_page => 15 )
    @matrices_otus = params[:sort_otus] ? Molecular::Matrix::Submatrix::SubmatrixOtus.sorted_by_cells(@submatrix) : @submatrix.submatrix_otus
    respond_to do |format|
      format.html { render 'show', layout: request.xhr? ? false : true }
      format.json { render json: {:info => {:timeline => @timeline, :matrix => @timeline.matrix, :versions => @timeline.matrix.timelines, :matrices_otus => @matrices_otus }}}
    end
  end

  def change_position
    msg = ''
    begin
      obj_type = "Molecular::Matrix::Submatrix::Submatrix" + params[:type].capitalize.pluralize
      @object = obj_type.constantize.where("submatrix_id = ? and " + params[:type] + "_id = ?", params[:id], params[:item_id]).first
      original_position = @object.position
      unless @object.nil?
        obj_type.constantize.transaction do
          @object.try(params[:move])
        end
      else
        msg = "Sorry, object not found"
      end
      msg = "not moved" if original_position == @object.position
    rescue RuntimeError => e
      msg = e.to_s
    rescue => e
      msg = e.to_s
    end
    if msg.blank? then head :ok else respond_to{|format| format.json { render json: msg == "not moved" ? {:no_move => true} : {:error => msg } } } end
  end

end