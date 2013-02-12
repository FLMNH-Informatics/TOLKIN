require 'bio'

class Morphology::MatricesController < ApplicationController
  include Restful::Responder
  include Morphology::MatricesHelper
  before_filter :set_project_variable
  before_filter :requires_project_guest
  before_filter :requires_project_updater, :except => [:index, :show]
  before_filter :requires_selected_project

  def create
    Morphology::Matrix.transaction do
      @matrix = Morphology::Matrix.create!(:name => params[:name])
      @timeline = Morphology::Matrix::Timeline.create!(:description => params[:description],
                                                       :matrix_id => @matrix.id
      )
    end
    respond_to{|format|format.json{render :json => {:id => @timeline.id}}}
  end

  def edit
    get_objs
    @matrix = @timeline.matrix
    respond_to{|format| format.html { render 'edit', layout: request.xhr? ? false : 'application' } }
  end

  def update
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    @timeline.matrix.name = params[:name]
    @timeline.description = params[:description]
    @timeline.save!
    @timeline.matrix.save!
    respond_to{ |format| format.json { render json: { :html => render_to_string('_matrix_title.html.haml') } } }
  end

  def update_info
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    @timeline.matrix.name = params[:name]
    @timeline.description = params[:description]
    @timeline.save!
    @timeline.matrix.save!
    respond_to{ |format| format.json { render json: { :html => render_to_string('_matrix_title.html.haml') } } }
  end

  def index
    query_params_provided? ||
      params.merge!(
        select: [:*],
        limit: 20
      )
    super current_project.morphology_matrix_views
  end
  
  def new
    super current_project.morphology_matrices
  end

  def show_view_by_date
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    respond_to do |format|
      format.html { render 'show_view_by_date', layout: request.xhr? ? false : 'application' }
    end
  end

  def view_by_date
    date = params[:date].to_datetime.utc
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    @matrices_characters = Morphology::Matrix::MatricesCharacters.includes(:character).where("timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)", params[:id], date, date).order('position')
    @characters = @matrices_characters.map{|mc|mc.character}
    @matrices_otus = Morphology::Matrix::MatricesOtus.includes(:otu).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', params[:id], date, date).order('position')
    @tooltips = get_tooltips(@characters.map{|c|c.id})
    respond_to do |format|
      format.html { render 'view_by_date', layout: request.xhr? ? false : true }
      format.json { render json: {:info => {:timeline => @timeline, :matrix => @timeline.matrix, :versions => @timeline.matrix.timelines, :matrices_otus => @matrices_otus }}}
    end
  end

  def show_next_version
    timeline = Morphology::Matrix::Timeline.find(params[:id])
    @timeline = timeline.create_next_version
    @matrix = timeline.matrix
    respond_to{|format| format.html { render 'edit', layout: request.xhr? ? false : 'application' } }
  end

  def show_view_by_date
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    respond_to do |format|
      format.html { render 'show_view_by_date', layout: request.xhr? ? false : 'application' }
    end
  end

  def get_times_for_date
    start_time = params[:date] + '000000'
    end_time   = params[:date] + '235959'
    datetimes = []
    ["Cell", "MatricesCharacters", "MatricesOtus"].each do |obj|
      ( (obj == "Cell" ? "Morphology::Matrix::" : "Morphology::Matrix::") + obj ).constantize.where('timeline_id = ? and create_date <= ? and create_date >= ?', params[:id], end_time.to_datetime, start_time.to_datetime).each{|item| datetimes << item.create_date}
    end
    respond_to do |format|
      format.json { render :json => { :times => datetimes.uniq.sort.inject([]){|memo, time| memo.push([time.strftime("%T"), time.to_s(:number)])}.to_json}}
    end
  end

  def get_tooltips(chr_id_array)
    tooltips = Morphology::Matrix::Timeline.get_states_for_tooltip(chr_id_array)
    tooltips.to_json
  end

  def show
    if params[:sort_both] and params[:sort_both] == "true"
      params[:sort_characters] = true
      params[:sort_otus] = true
    end
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    timeline_id = params[:id]
    if params[:sort_characters].nil?
      @characters = @timeline.characters.paginate(:page => params[:page], :per_page => 15, :order => "morphology_matrices_characters.position")
    else
      character_sql = %(
        SELECT mchar.*, coalesce(mcells_count.cells_count,0) as cells_count
        FROM morphology_matrices_characters mchar
          LEFT OUTER JOIN
            (
              SELECT character_id, count(character_id) as cells_count
              FROM morphology_matrix_cells
              WHERE timeline_id = #{timeline_id} and is_active = true
              GROUP BY character_id
            ) as mcells_count
          ON mchar.character_id = mcells_count.character_id
        WHERE mchar.timeline_id = #{timeline_id}
        ORDER BY mcells_count.cells_count desc nulls last, mchar.position
      )
      @matrices_characters = Morphology::Matrix::MatricesCharacters.find_by_sql(character_sql)
      @characters = @matrices_characters.map{|mc|mc.character}.paginate(:page => params[:page], :per_page => 15)
    end
    if params[:sort_otus].nil?
      @matrices_otus = @timeline.matrices_otus
    else
      motu_sql = %(
        SELECT motu.*, coalesce(mcells_count.cells_count,0) as cells_count
        FROM morphology_matrices_otus motu
          LEFT OUTER JOIN
            (
              SELECT otu_id, count(otu_id) as cells_count
              FROM morphology_matrix_cells
              WHERE timeline_id = #{timeline_id} and is_active = true
              GROUP BY otu_id
            ) as mcells_count
          ON motu.otu_id = mcells_count.otu_id
        WHERE motu.timeline_id = #{timeline_id}
        ORDER BY mcells_count.cells_count DESC NULLS LAST, motu.position
      )
      @matrices_otus = Morphology::Matrix::MatricesOtus.find_by_sql(motu_sql)
    end
    @tooltips = get_tooltips(@characters.map{|c|c.id})
    respond_to do |format|
      format.html { render 'show', layout: request.xhr? ? false : true }
      format.json { render json: {:info => {:timeline => @timeline, :matrix => @timeline.matrix, :versions => @timeline.matrix.timelines, :matrices_otus => @matrices_otus, } } }
    end
  end

  def load_row
    date = ( params["date"] || Time.now).to_datetime.utc
    @motu = Morphology::Matrix::MatricesOtus.find(params["matrix_otu_id"])
    character_ids = params[:y_ids]
    @cells_array = character_ids.collect do |character_id|
      [Morphology::Matrix::Cell.where('timeline_id = ? and otu_id = ? and character_id = ? and create_date <= ? and (overwrite_date >= ? or overwrite_date IS NULL)', params[:id], params[:otu_id], character_id, date, date).first, params[:otu_id], character_id]
    end if character_ids
    respond_to{|format|format.json{render json: {:row => row_builder(@motu)}}}
  end
  
  #def show
  #  if params[:sort_characters].nil?
  #    get_objs_by_date
  #    @characters = @characters.paginate(:page => params[:page], :per_page => 15, :order => "morphology_matrices_characters.position")
  #    @tooltips = get_tooltips(@characters.map{|c|c.id})
  #    ordered_otu_ids = Morphology::Matrix::MatricesOtus.select('otu_id, position')
  #      .where(
  #        {:timeline_id => @timeline.id} &
  #        ((:delete_date >= DateTime.now.utc) | {:delete_date => nil})
  #      ).order('morphology_matrices_otus.position').map{|mo|[mo.otu_id,mo.position]}
  #    character_sql = @timeline.matrices_characters.in_list.empty? ? " " : " JOIN (
  #        values
  #        #{@timeline.matrices_characters.in_list
  #            .paginate(:page => params[:page], :per_page => 15, :order => 'position')
  #            .collect{|m| [m.character_id, m.position]}.to_s.gsub('[','(').gsub(']',')')[1..-2]}
  #      ) as characters (id, ordering) on cells.character_id = characters.id
  #    "
  #    otu_sql = @timeline.matrices_otus.in_list.empty? ? " " : " JOIN (
  #        values
  #        #{ordered_otu_ids.to_s.gsub('[','(').gsub(']',')')[1..-2]}
  #      ) as otus (id, ordering) on cells.otu_id = otus.id"
  #    otus_ordering = @timeline.matrices_otus.in_list.empty? ? " " : " otus.ordering"
  #    characters_ordering = @timeline.matrices_characters.in_list.empty? ? " " : " characters.ordering"
  #    order_by = (@timeline.matrices_otus.in_list.empty? && @timeline.matrices_characters.in_list.empty?) ? "" : " ORDER BY "
  #    comma = (!@timeline.matrices_otus.in_list.empty? && !@timeline.matrices_characters.in_list.empty?) ? "," : ""
  #    sql = "
  #      SELECT cells.*
  #      FROM morphology_matrix_cells cells
  #      " + character_sql +  otu_sql + "
  #      WHERE
  #        cells.timeline_id = #{@timeline.id} and
  #        cells.is_active = true and
  #        (cells.overwrite_date >= timestamp '#{DateTime.now.utc}' or cells.overwrite_date is null)
  #        " + order_by + otus_ordering + comma + characters_ordering + ";"
  #    @cells = Morphology::Matrix::Cell.find_by_sql(sql)
  #  else
  #    @timeline = Morphology::Matrix::Timeline.includes(:matrices_otus).find(params[:id])
  #    character_ids_containing_cells = Morphology::Character
  #      .joins(:cells)
  #      .joins(:matrices_characters)
  #      .select('characters.id')
  #      .group('characters.id')
  #      .where(
  #        {:cells =>
  #           { :timeline_id => @timeline.id } &
  #             ({:is_active => true} |
  #             ( :overwrite_date >= DateTime.now.utc))
  #        } | {
  #         :matrices_characters =>
  #           {:timeline_id => @timeline.id } &
  #           ((:delete_date >= DateTime.now.utc) | (:delete_date >> nil))
  #        }
  #      ).order(
  #        :cells =>
  #          (:count.func('morphology_matrix_cells.character_id'))
  #      ).map{|m|m.id}.reverse
  #    character_ids_containing_cells.paginate(:page => params[:page], :per_page => 15).each_with_index{|m_id, i| character_ids_containing_cells[i] = [m_id, (i+1)]}
  #    @matrices_otus = @timeline.matrices_otus
  #    @otus = @matrices_otus.map{|mo|mo.otu}
  #    ordered_otu_ids = Morphology::Matrix::MatricesOtus.select('otu_id, position')
  #      .where(
  #        {:timeline_id => @timeline.id} &
  #        ((:delete_date >= DateTime.now.utc) | {:delete_date => nil})
  #      ).order('morphology_matrices_otus.position').map{|mo|[mo.otu_id,mo.position]}
  #    @characters = (character_ids_containing_cells.map{|mrk|Morphology::Character.find(mrk.first)} | @timeline.characters).paginate(:page => params[:page], :per_page => 15)
  #    @tooltips = get_tooltips(@characters.map{|c|c.id})
  #    sql = "
  #      SELECT cells.*
  #      FROM morphology_matrix_cells cells
  #      JOIN (
  #        values
  #        #{character_ids_containing_cells.to_s.gsub('[','(').gsub(']',')')[1..-2]}
  #      ) as characters (id, ordering) on cells.character_id = characters.id
  #      JOIN (
  #        values
  #        #{ordered_otu_ids.to_s.gsub('[','(').gsub(']',')')[1..-2]}
  #      ) as otus (id, ordering) on cells.otu_id = otus.id
  #      WHERE
  #        cells.timeline_id = #{@timeline.id} and
  #        cells.is_active = true and
  #        (cells.overwrite_date >= timestamp '#{DateTime.now.utc}' or cells.overwrite_date is null)
  #      ORDER BY
  #        otus.ordering, characters.ordering
  #    "
  #    @cells = Morphology::Matrix::Cell.find_by_sql(sql)
  #  end
  #  respond_to do |format|
  #    format.html { render 'show', layout: request.xhr? ? false : true }
  #    format.json { render json: {:info => {:timeline => @timeline, :matrix => @timeline.matrix, :versions => @timeline.matrix.timelines }}}
  #    #format.xml  { render xml:  result.to_xml(params) }
  #  end
  #end
  
  def show_copy_matrix
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    respond_to{|format| format.html { render 'edit', layout: request.xhr? ? false : 'application' } }
  end
  
  def modify_matrix
    get_objs
  end
  
  def copy_matrix
    date = (params[:date].nil? ? DateTime.now : params[:date].to_datetime).utc
    #TODO timeline functions to get by date
    timeline = Morphology::Matrix::Timeline.find(params[:id])
    @timeline = timeline.copy(date)
    @timeline.update_attributes(:description => (params[:description] + " " + @timeline.description))
    @matrix = @timeline.matrix
    @matrix.update_attributes(:name => params["name"])
    respond_to{|format| format.json { render :json => {:id => @timeline.id, :name => @matrix.name, :description => @timeline.description} } }
  end
  
  def change_position
    begin
      obj_type = "Morphology::Matrix::" + "Matrices" + params[:type].capitalize.pluralize
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
    super current_project.morphology_matrix_timelines
  end

  def show_add_character
    @character = Morphology::Character.new
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    respond_to do |format|
      format.html { render 'show_add_character', layout: request.xhr? ? false : 'application' }
    end
  end

  def show_add_otu
    @otu = Otu.new
    respond_to do |format|
      format.html { render 'show_add_otu', layout: request.xhr? ? false : 'application' }
    end
  end

  def update_otu
    @timeline  = Morphology::Matrix::Timeline.find(params[:id])
    begin
      Otu.transaction do
        raise 'neither an OTU nor an OTU group has been selected' if params[:otu][:name].blank? and params[:otu_group_id].blank?
        otus_to_add = params[:otu][:name].blank? ? current_project.otu_groups.find(params[:otu_group_id]).otus : [ current_project.otus.active.find_by_name(params[:otu][:name]) ]
        fail("otus to add not found") if otus_to_add.compact.empty?
        existing_otus = @timeline.matrices_otus.in_list.map{|mo|mo.otu}
        otus_to_add.each{ |otu| @timeline.otus << otu unless @timeline.matrices_otus.in_list.map{|mo|mo.otu}.include?(otu) }
      end
      @timeline.reload
      @matrices_otus = @timeline.matrices_otus
      flash[:notice] = "OTU(s) successfully added."
    rescue ActiveRecord::RecordNotSaved => e
      flash[:error] = "Error adding OTU(s): #{e.message} "
    rescue RuntimeError => e
      flash[:error] = "Error adding OTU(s): #{e.message} "
    rescue => e
      log_error e
      flash[:error] = "Error adding OTU(s): #{e.message}"
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
  
  def update_character
    @project = current_project
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    begin
      Morphology::Character.transaction do
        raise "neither a character nor a character group has been selected" if params[:character][:name].blank? and params[:chr_group_id].blank?
        chrs_to_add = params[:character][:name].blank? ? current_project.chr_groups.find(params[:chr_group_id]).characters : [ current_project.characters.active.find_by_name(params[:character][:name]) ]
        fail("Characters to add not found") if chrs_to_add.compact.empty?
        existing_characters = @timeline.matrices_characters.in_list.map{|mc|mc.character}
        chrs_to_add.each{|char| char.add_to_timeline(@timeline) unless existing_characters.include?(char)}
        flash[:notice] = "All characters added successfully."
      end
      @timeline.reload
      @matrices_characters = @timeline.matrices_characters
    rescue => e
      log_error e unless e.kind_of?(RuntimeError) || e.kind_of?(ActiveRecord::RecordNotSaved)
      flash[:error] = "Error Adding Character(s): #{e.message}"
    end
     if e
      respond_to do |format|
        format.json { render :json => {:message => e.message}.to_json }
      end
    else
      respond_to do |format|
        format.html { redirect_to(modify_matrix_project_morphology_matrix_path(params[:project_id], @matrix)) }
        format.xml  { head :ok }
        format.js   { head :ok }
        format.json { render :json => { :char_list => render_to_string(:partial => "modify_matrix_characters.html.erb")} }
      end
    end
  end
  
  def remove_otu
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    otus = *Otu.find(params[:otu_id])
    otus.each{|o|@timeline.remove_otu(o)}
    get_objs
    respond_to do |format|
      format.js { head :ok}
      format.html { redirect_to (modify_matrix_project_morphology_matrix_path(params[:project_id], @timeline)) }
      format.json{render :json => {:list => render_to_string(:partial => "modify_matrix_otus.html.erb")}}
    end
  end

  def remove_character
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    characters = *Morphology::Character.find(params[:character_id])
    begin
      Morphology::Character.transaction do
        characters.each{|chr|@timeline.remove_character(chr)}
      end
      @timeline.reload
      @matrices_characters = @timeline.matrices_characters
      flash[:notice] = 'Character(s) removed from matrix.'
    rescue => e
      flash[:error] = 'Error removing character.'
      log_error e
    end
    respond_to do |format|
      format.html { redirect_to modify_matrix_project_morphology_matrix_path(params[:project_id], params[:id]) }
      format.xml  { head :ok }
      format.js
      format.json { render :json => {:list => render_to_string(:partial => "modify_matrix_characters.html.erb")}}

    end
  end
  
  def set_project_variable
    @project = current_project
  end

  def do_export
    filename = 'nexus.nex'
    @timeline = Morphology::Matrix::Timeline.includes(:matrices_otus, :otus, :matrices_characters, :characters, :cells).find(params[:id])
    file = @timeline.export_to_nexus(filename)
    send_file(file, :disposition => 'attachment')
    #respond_to do |format|
    #  format.html { redirect_to(project_morphology_matrix_path(params[:project_id],@timeline.id))  }
    #  format.xml  { head :ok }
    #  format.js   {
    #    @ajax_response_top = params[:ajax_response_top]
    #  }
    end

  private
  def get_objs(object_type = 'all')
    @project          = current_project
    @timeline         = Morphology::Matrix::Timeline.includes(:matrix).find(params[:id])
    #@matrices_otus   = @timeline.matrices_otus.includes(:otu)          unless object_type == "character"
    @matrices_otus    = Morphology::Matrix::MatricesOtus.includes(:otu).where('timeline_id = ? and (delete_date is null)', params[:id]).order('position')  unless object_type == "character"
    @matrices_characters = Morphology::Matrix::MatricesCharacters.includes(:character).where('timeline_id = ? and delete_date is null', params[:id]).order('position') unless object_type == "otu"
    #@matrices_characters = @timeline.matrices_characters.includes(:character)    unless object_type == "otu"
  end

  def get_objs_by_date(cells = false, date = DateTime.now())
    date = date.utc
    @matrices_characters = Morphology::Matrix::MatricesCharacters.includes(:character).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', params[:id], date, date).order('position, delete_date')
    @matrices_otus    = Morphology::Matrix::MatricesOtus.includes(:otu).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', params[:id], date, date).order('position, delete_date')
    @timeline = Morphology::Matrix::Timeline.find(params[:id])
    @cells = Morphology::Matrix::Cell.find_by_timeline_and_date(@timeline, date) if cells == true
    @characters = @matrices_characters.map{|mchar|mchar.character}
    @otus = @matrices_otus.map{|motu|motu.otu}
  end

end






















#require 'restful/responder'
#class Morphology::MatricesController < ApplicationController
#  include Restful::Responder
#  before_filter :params_to_hash
#  before_filter :requires_selected_project
#  before_filter :requires_project_guest, :only => [ :index, :show, :get_states, :redirect_to_version, :do_export ]
#  before_filter :requires_project_updater, :only => [ :new, :edit, :create, :update, :add_otu,
#    :add_submatrix, :update_otu, :update_character, :add_character, :update_state_codings,
#    :modify_matrix, :change_position, :commit_changes, :merge_with_parent,
#    :revert_to_version, :remove_chr, :remove_otu, :copy_matrix, :merge, :revert_change ]
#  #before_filter :requires_project_manager, :only => [ :destroy, :delete_selected, :destroy_branch ]
#  #this could be an only based option as many of the actions are not using the return_working_matrix options ?
#  before_filter :return_working_matrix, :except => [ :index, :new, :create, :show_merge_matrices, :show_copy_matrix, :show_merge_window, :show_designate_submatrix, :auto_complete_for_otu_name,
#    :auto_complete_for_branch_name, :auto_complete_for_character_name, :select_for_branch_version, :merge, :delete_selected ,
#    :process_index_modify_matrix, :revert_change, :revert_all_changes, :show_designate_submatrix_window, :designate_submatrix ]
#
#  before_filter :show_commit_changes_notice, :only => [ :copy_matrix, :do_export, :create_submatrix ]
#
#  before_filter :otu_groups_list, :only => [:show, :modify_matrix]
#
#  auto_complete_for :otu, :name, :project_scope => true, active_scope: true
#  auto_complete_for 'Matrix::Branch', :name, :project_scope => true
#  auto_complete_for 'Morphology::Character', :name, :project_scope => true, active_scope: true
#
#  helper "Morphology::Matrices"
#  def create
##    begin
##      @matrix = Morphology::Matrix::Checkpoint.create_initial params[:matrix]
##      flash[:notice] = 'Matrix was successfully created.'
##      @matrix_branches = current_project.branches.for_morphology_matrices.sort_by { |branch| branch.updated_at }.reverse
##
##      respond_to do |format|
##  #      format.html { redirect_to(project_morphology_matrix_path(params[:project_id],@matrix)) }
##        format.json { render json: { id:  @matrix.to_s } }
##      end
##    rescue => e
##      debugger
##      log_error e unless e.class == ActiveRecord::RecordNotSaved
##      flash[:error] = "Error creating matrix: #{e.message}"
##    end
#    begin
#      matrix_hash = params[:matrix]
#      @project = current_project
#      Morphology::Matrix::Checkpoint.transaction do
#        unless params[:copy_data_from].blank?
#          @copy_from_matrix = Morphology::Matrix.for_matrix_address(Matrix::Address.from_s(params[:parent]))
#          object_history = @copy_from_matrix.history
#          @branch = @branch = object_history.branches.create!(:branch_number => object_history.latest_branch_number + 1, :name => matrix_hash[:name], :description => matrix_hash[:description], :parent_id => Matrix::Address.from_s(params[:parent]).branch.id, :item_type => 'Morphology::Matrix')
#          branch_item = @copy_from_matrix.branch_item
#        else
#          object_history = Matrix::History.create!(:item_type => "Morphology::Matrix")
##          debugger
#          @matrix = Morphology::Matrix::Checkpoint.create!
#          branch_item = Matrix::BranchItem.create!(:item => @matrix)
#          branch_item.project_id = @matrix.project_id
#          @branch = object_history.branches.create!(:branch_number => 1, :name => matrix_hash[:name].strip, :description => matrix_hash[:description], :item_type => 'Morphology::Matrix', :project_id => branch_item.project_id)
#        end
#
#        Matrix::BranchItemsBranch.create!(:branch_item => branch_item, :branch => @branch, :position => 0)
#        @matrix = @branch.max_branch_item.item if @matrix.nil?
#      end
#      #filling the attributes and other things for listing index
#      matrix_list_attributes_and_properties
#      @main_branches = @project.branches.for_morphology_matrices.sort_by { |branch| branch.updated_at }.reverse
#      flash[:notice] = 'Matrix was successfully created.'
#      respond_to do |format|
#        format.html { redirect_to(project_morphology_matrix_path(params[:project_id],@matrix)) }
#        format.js
#      end
#    rescue ActiveRecord::RecordNotSaved => e
#      fail "Error creating matrix: #{e.message}"
#    rescue => e
#      fail "Error creating matrix: #{e.message}"
#    end
#  end
#
#  def create_submatrix
#    matrix_hash = params[:matrix]
#    @project = current_project
#
#    Morphology::Matrix::Checkpoint.transaction do
#      unless params[:copy_data_from].blank?
#        @copy_from_matrix = @matrix
#        object_history = @copy_from_matrix.history
#        @branch = object_history.branches.create!(:branch_number => object_history.latest_branch_number + 1, :name => matrix_hash[:name], :description => matrix_hash[:description], :parent_id => @matrix.branch.id, :item_type => 'Morphology::Matrix')
#        branch_item = @copy_from_matrix.branch_item
#      else
#        object_history = Matrix::History.create!(:item_type => "Morphology::Matrix")
#        @new_matrix = Morphology::Matrix::Checkpoint.create!
#        branch_item = Matrix::BranchItem.create!(:item => @new_matrix)
#        @branch = object_history.branches.create!(:branch_number => 1, :name => matrix_hash[:name].strip, :description => matrix_hash[:description], :parent_id => @matrix.branch.id, :item_type => 'Morphology::Matrix')
#      end
#      Matrix::BranchItemsBranch.create!(:branch_item => branch_item, :branch => @branch, :position => 1)
#    end
#    @new_matrix_address = Matrix::Address.from_branch_info(@branch, 1)
#    @destination = project_morphology_matrix_path current_project, @new_matrix_address
#    flash[:notice] = 'Matrix was successfully created.'
#
#    respond_to do |format|
#      format.html { redirect_to @destination }
#      format.js { render 'shared/redirect'}
#    end
#  end
#
#  def delete_selected
#    @project = current_project
#    #begin
#      #@ele_id_prefix = params[:form_id] || "list_item_"
#      @sel_matrices = params[:selected_items] || params[:data] || []
#      @deleted_items = []
#      @perm_denied_items = []
#      error_message = ""
#      Morphology::Matrix::Checkpoint.transaction do
#        @sel_matrices.each do |matrix_id|
#          branch = Matrix::Address.from_s(matrix_id).branch
#          if project_manager_or_owner?(branch)
#            branch.destroy
#            @deleted_items << branch
#          else
#            @perm_denied_items << branch
#          end
#        end
#      end
#      error_message << @deleted_items.collect{|item| item.name}.join(', ') + " deleted successfully." unless @deleted_items.empty?
#      error_message  << @perm_denied_items.collect{|item| item.name}.join(', ') + " could not be deleted, you need to be an owner or manager." unless @perm_denied_items.empty?
#      flash[:notice] = error_message
##    rescue
##      flash[:error] = "Matrices could not be deleted"
##    end
#      respond_to do |format|
#        format.html { head :ok}
#      end
#      #redirect_to(project_morphology_matrices_path(params[:project_id]))
#  end
#
#  def destroy_branch
#    begin
#      if project_manager_or_owner?(@matrix.branch)
#        Matrix::Branch.transaction do
#          @matrix.branch.destroy
#        end
#        flash[:notice] = "Matrix and submatrices successfully destroyed."
#      else
#        flash[:error] = "Matrix could not be deleted. You must be an owner  of the record or manger for the project to delete the matrix branch."
#      end
#    rescue => e
#      flash[:error] = "Matrix could not be deleted. #{e.message}"
#    end
#    redirect_to project_morphology_matrices_path(params[:project_id])
#  end
#
#  def destroy
#    raise "Exception Destory Not Implemented"
#    @matrix.children.each { |c|
#      c.delete_matrix_data
#      c.destroy
#    }
#
#    if @matrix.destroy
#      flash[:notice] = 'Matrix deleted.'
#    else
#      flash[:notice] = 'Error deleting matrix.'
#    end
#
#    respond_to do |format|
#      format.html { redirect_to(project_morphology_matrices_path(params[:project_id])) }
#      format.xml  { head :ok }
#      format.js
#    end
#  end
#
#  def edit
#    @project = Project.find(params[:project_id])
#    #@matrix = Morphology::Matrix.find(params[:id])
#  end
#
#  def index
#    begin
#      #TODO: rss still not properly allowed
#      #FIXME: letting through all xhr and rss requests for now - needed for public taxa pages, not ideal
#      if current_user != User.public_user || request.xhr? || request.format.rss?
#        query_params_provided? ||
#          params.merge!(
#            select: [ :id, :name, :description, :creator_id, :parent_id, :object_history_id, :matrix_id, :branch_number, :created_at, :updated_at, :updater_name ],
#            include: {
#              parent: { select: [ :id, :name ] },
#              object_history: { select: [ :id ] },
#              creator: { select: [ :user_id, :full_name] }
#            },
#            order: [  'created_at DESC' ],
#            limit: 20
#        )
#        super current_project.branches.active.for_morphology_matrices
#      else
#        permission_denied
#      end
#      rescue => e
#        debugger
#        "hello"
#    end
#
#
#
#
##    params.include?(:select) || params[:select] = [
##      'id',
##      'name',
##      'description',
##      'parent.name',
##      'updater_label',
##      'updated_at',
##      'creator.label',
##      'created_at',
##      'matrix_id',
##      'branch_number',
##      'parent_id',
##      'creator_id',
##      'object_history_id',
##    ]
##    params.include?(:include) || params[:include] = [ :parent, :creator, :object_history ]
##    params.include?(:limit) || params[:limit] = '20' #FIXME: hardcoded for now because morphology matrix catalog not properly sending limit parameter
##    params.include?(:order) || params[:order] = 'created_at DESC' #FIXME: hardcoded for now because morphology matrix catalog not properly sending order parameter
##    debugger
##    super current_project.branches.active.for_morphology_matrices #do |collection|
#      #collection.entries.each do |branch|
#        # temporary hack to make it possible to store id of the form \d+-\d+-\d+ as id so that to_json
#        # will return useful id value
#        #def branch.matrix_id; max_address.to_s end
#        #def branch.id=(value); @id = value end
#        #branch.updater.try(:label) # needed for updater_label to work correctly with id change
#        #branch.id = branch.max_address.to_s
#      #end
#    #end
#  end
#
#  def tagged_matrices
#    tags = {} #hash of tags and their respective matrices in an array. would look like :key => [list of matrices]
#    Tagging.find_all_by_taggable_type("Matrix::Branch").each do |tagging|
#      tags[tagging.tag.name] = Array.new  if tags[tagging.tag.name].nil?
#      tags[tagging.tag.name] << tagging.taggable if (tagging.taggable && !tags[tagging.tag.name].include?(tagging.taggable))
#    end
#    tags.each do |key, val|
#      tags.delete(key) if (val.nil? or val.empty?)
#    end
#    tags
#  end
#
#  def new
#    @matrix = Morphology::Matrix::Checkpoint.new
#    respond_to do |format|
#      format.html { render :partial => 'new_matrix', :layout => false }# new.html.erb
#      format.xml  { render :xml => @matrix }
#      format.js
#    end
#  end
#
#  def new_submatrix
#    respond_to do |format|
#      format.js { @window_name = :new_submatrix_window; render "shared/show_window" }
#    end
#  end
#
#  # ajax function that redirects to a new version on the same branch as the current matrix if it exists
#  def redirect_to_version
#    new_address = Matrix::Address.new(@matrix.object_history.id, @matrix.branch.branch_number, params[:version_number].to_i)
#    if new_address.is_valid?
#      destination = project_morphology_matrix_path(current_project, new_address)
#    else
#      flash[:error] = "Invalid version number was given."
#      destination = :back
#    end
#    respond_to do |format|
#      format.html { redirect_to destination }
#    end
#  end
#
#  def show_revert_to_version
#    @project = Project.find(params[:project_id])
#    @branch = @matrix.branch
#    respond_to do |format|
#      format.js
#    end
#  end
#
#  def revert_to_version
#    begin
#      new_address = @matrix.branch.revert_to_version(params[:matrix][:version_number])
#      destination = project_morphology_matrix_path(current_project, new_address)
#    rescue RuntimeError => e
#      flash[:error] = "Problem reverting: #{e.message}"
#      destination = :back
#    end
#
#    respond_to do |format|
#      format.html { redirect_to destination }
#    end
#  end
#
#  def show_copy_matrix
#    @matrix = Morphology::Matrix.new
#    respond_to do |format|
#      format.html { render 'show_copy_matrix', layout: request.xhr? ? false : 'application' }
#    end
#  end
#
#  def show_copy_matrix_options_window
#    respond_to do |format|
#      format.js
#    end
#  end
#
#   def matrix_by_otu_group
#     if  params[:otu_group_id]
#            @matrix = Matrix::UserMatrix.for_address_and_user_and_project(Matrix::Address.from_s(params[:id]), current_user, @current_project, action_name != "modify_matrix" ? { :process_codings_changes => true, :page => params[:page] || 1, :group_id => params[:otu_group_id] , :query_for_codings => {:include => [ {:otu => { :otu_groups_otus => :otu_group }}] , :conditions => "otu_groups.id = "+ params[:otu_group_id].to_s}  } : { })
#     else
#             @matrix = Matrix::UserMatrix.for_address_and_user_and_project(Matrix::Address.from_s(params[:id]), current_user, @current_project, action_name != "modify_matrix" ? { :process_codings_changes => true, :page => params[:page] || 1 } : { })
#     end
#     params[:page] ||= "1"
#      @project = current_project
#      chr_id_array = @matrix.characters.collect {|chr| chr.id }
#      @tooltips = get_tooltips(chr_id_array)
#     render :partial => "matrix_by_otu_group"
#  end
#
#  def show_matrix_details
#    @allow_edit = true #TODO actually check record permissions here
#    respond_to { |format| format.js }
#  end
#
#  def copy_matrix
#    begin
#      Morphology::Matrix::Checkpoint.transaction do
#        if params[:branch][:copy_type] == "new"
#          object_history = @matrix.object_history
#          branch = object_history.new_branch(:item_type => 'Morphology::Matrix', :name => params[:branch][:name], :project_id => params[:project_id])
#          branch.save!
#        else
#          branch = current_project.branches.find :first, :conditions => "lower(name) = '#{params[:branch][:name].downcase}'"
#          raise "no matrix exists with the provided name" if branch.nil?
#        end
#
#        @new_matrix_address = branch.copy_from_matrix @matrix, params[:branch][:copy_type]
#        @destination = project_morphology_matrix_path current_project, @new_matrix_address
#        flash[:notice] = "Matrix successfully copied."
#      end
#    rescue RuntimeError => e
#      flash[:warning] = "Problem encountered copying matrix: #{e.message}"
#      @destination = project_morphology_matrix_path current_project, @matrix
#    rescue => e
#      flash[:error] = "Error encountered copying matrix: #{e.message}"
#      @destination = project_morphology_matrix_path current_project, @matrix
#    end
#
#    respond_to do |format|
#      format.js { render "shared/redirect"}
#      format.html { redirect_to @destination }
#    end
#  end
#
#  # ajax method for returning possible version number values for select field
#  def select_for_branch_version
#    branch = current_project.branches.for_morphology_matrices.find_by_name(params[:branch_name])
#    if branch
#      returnText = branch.versions.collect{|version| "<option>#{version}</option>"}.reverse.join
#    else
#      returnText = ''
#    end
#    render :text => returnText
#  end
#
#  def show
#    set_last_matrix_page
#    if @matrix.branch.project_id != current_project.project_id
#      redirect_to :action => 'index'
#    else
#      params[:page] ||= "1"
#      @project = current_project
#      chr_id_array = @matrix.characters.collect {|chr| chr.id }
#      @tooltips = get_tooltips(chr_id_array)
#
#      respond_to do |format|
#        format.html # show.html.erb
#        format.xml  { render :xml => @matrix }
#        format.js   { render :partial => 'matrix_table' }
#      end
#    end
#  end
#
#  def update
#    begin
#      @matrix.branch.update_attributes!(params[:matrix] || params[:branch] )
#      if request.format == :js
#        flash.now[:notice] = 'Matrix was successfully updated.'
#      else
#        flash[:notice] = 'Matrix was successfully updated.'
#      end
#    rescue => e
#      log_error e
#      if request.format == :js
#        flash.now[:error] = 'Matrix not updated: error encountered'
#      else
#        flash[:error] = 'Matrix not updated: error encountered'
#      end
#    end
#    respond_to do |format|
#      format.js { render :text => flash[:error] || flash[:notice], :status => flash[:error] ? :not_acceptable : :ok }
#      format.json { render :text => flash[:error] || @matrix.branch.send(params[:branch].keys.first), :status => flash[:error] ? :not_acceptable : :ok }
#      format.html { redirect_to(modify_matrix_project_morphology_matrix_path(current_project, @matrix)) }
#      format.xml  { head :ok }
#    end
#  end
#
#  def remove_character
#    begin
#      @chr_ids =params[:chr_id] || params[:chr_ids] || []
#      Morphology::Character.transaction do
#        [*@chr_ids].each do |chr_id|
#          @character = current_project.characters.find(chr_id)
#          parent_item = @matrix.changeset.items.create!(:change_type => ChangeTypes::REMOVE, :old_version => @character, :move_to_prev_position => @matrix.characters.index(@character) + 1)
#          @matrix.codings.fetch_for_x(@character.id).each do |coding|
#            @matrix.changeset.items.create!(:change_type => ChangeTypes::REMOVE, :old_version => coding, :parent => parent_item)
#          end
#        end
#      end
#      flash[:notice] = 'Character(s) removed from matrix.'
#    rescue => e
#      flash[:error] = 'Error removing character.'
#      log_error e
#    end
#    respond_to do |format|
#      format.html { redirect_to modify_matrix_project_morphology_matrix_path(params[:project_id], params[:id]) }
#      format.xml  { head :ok }
#      format.js
#    end
#  end
#
#  def remove_otu
#    begin
#      @otu_ids = params[:otu_id] || params[:otu_ids] || []
#      @otu_ids = [*@otu_ids]
#      Otu.transaction do
#        @otu_ids.each do |otu_id|
#          @otu = current_project.otus.find(otu_id)
#          parent_item = @matrix.changeset.items.create!(:change_type => ChangeTypes::REMOVE, :old_version => @otu, :move_to_prev_position => @matrix.otus.index(@otu) + 1)
#          @matrix.codings.fetch_for_y(@otu.id).each do |coding|
#            @matrix.changeset.items.create!(:change_type => ChangeTypes::REMOVE, :old_version => coding, :parent => parent_item)
#          end
#        end
#      end
#      flash[:notice] = 'Otu(s) removed from matrix.'
#    rescue => e
#      flash[:error] = 'Error removing otu. Reason: ' + e.to_s
#      log_error e
#    end
#    respond_to do |format|
#      format.html { redirect_to (modify_matrix_project_morphology_matrix_path(params[:project_id], @matrix)) }
#      format.xml  { head :ok }
#      format.js
#    end
#  end
#
#  def show_add_otu
#    @otu = Otu.new
#    respond_to do |format|
#      format.html { render 'show_add_otu', layout: request.xhr? ? false : 'application' }
##      format.js
#    end
#  end
#
#  def add_otu
#    @project = current_project
#    @otu_groups = @project.otu_groups
#    respond_to do |format|
#      format.html { redirect_to(modify_matrix_project_morphology_matrix_path(params[:project_id], params[:id])) }
#      format.xml  { head :ok }
#      format.js
#    end
#  end
#
#  def update_otu
#    @project = current_project
#    begin
#      Otu.transaction do
#        raise 'neither an OTU nor an OTU group has been selected' if params[:otu][:name].blank? and params[:otu_group_id].blank?
#        @otus_to_add = params[:otu][:name].blank? ? current_project.otu_groups.find(params[:otu_group_id]).otus : [ current_project.otus.active.find_by_name(params[:otu][:name]) ]
#        fail("otus to add not found") if @otus_to_add.compact.empty?
#        Otu.add_to_matrix(@matrix.otus, @otus_to_add, @matrix.changeset)
#        unless params[:otu_group_id].blank?
#          @mor_otu = Morphology::Matrix::MorphologyMatricesOtuGroups.find(:all, :conditions => ["otu_group_id = ? and matrix_checkpoint_id = ?", params[:otu_group_id],@matrix.checkpoint.id])
#           if @mor_otu.length == 0
#              Morphology::Matrix::MorphologyMatricesOtuGroups.add_otu_group_to_matrix({:matrix_checkpoint_id => @matrix.checkpoint.id, :otu_group_id => params[:otu_group_id].to_i , :creator_id => current_user.id , :updater_id => current_user.id })
#           end
#        end
#      end
#      flash[:notice] = "OTU(s) successfully added."
#    rescue ActiveRecord::RecordNotSaved => e
#      flash[:error] = "Error adding OTU(s): #{e.message} "
#    rescue RuntimeError => e
#      flash[:error] = "Error adding OTU(s): #{e.message} "
#    rescue => e
#      log_error e
#      flash[:error] = "Error adding OTU(s): #{e.message}"
#    end
#    if e
#      respond_to do |format|
#        format.json { render :json => {:message => e.message}.to_json }
#      end
#    else
#      respond_to do |format|
#        format.html { redirect_to(modify_matrix_project_morphology_matrix_path(params[:project_id], @matrix)) }
#        format.xml  { head :ok }
#        format.js   { head :ok }
#        format.json { head :ok }
#      end
#    end
#  end
#
#  def update_character
#    @project = current_project
#    begin
#      raise "neither a character nor a character group has been selected" if params[:character][:name].blank? and params[:chr_group_id].blank?
#
#      @chrs_to_add = params[:character][:name].blank? ? current_project.chr_groups.find(params[:chr_group_id]).characters : [ current_project.characters.active.find_by_name(params[:character][:name]) ]
#      Morphology::Character.add_to_matrix(@matrix.characters, @chrs_to_add, @matrix.changeset)
#
#      flash[:notice] = "All characters added successfully."
#      #    rescue ActiveRecord::RecordNotSaved => e
#      #      flash[:error] = 'Error Adding Character(s)'
#      #    rescue RuntimeError => e
#      #      flash[:error] = "Error Adding Character(s): #{e.message}"
#    rescue => e
#      log_error e unless e.kind_of?(RuntimeError) || e.kind_of?(ActiveRecord::RecordNotSaved)
#      flash[:error] = "Error Adding Character(s): #{e.message}"
#    end
#     if e
#      respond_to do |format|
#        format.json { render :json => {:message => e.message}.to_json }
#      end
#    else
#      respond_to do |format|
#        format.html { redirect_to(modify_matrix_project_morphology_matrix_path(params[:project_id], @matrix)) }
#        format.xml  { head :ok }
#        format.js   { head :ok }
#        format.json { head :ok }
#      end
#    end
#  end
#
#  def show_add_character
#    @character = Morphology::Character.new
#    respond_to do |format|
#      format.html { render 'show_add_character', layout: request.xhr? ? false : 'application' }
##      format.js
#    end
#  end
#
#  def add_character
#    @project = Project.find(params[:project_id])
#    @chr_groups = @project.chr_groups
#    respond_to do |format|
#      format.html { redirect_to(modify_matrix_project_morphology_matrix_path(params[:project_id], @matrix))  }
#      format.xml  { head :ok }
#      format.js
#    end
#  end
#
#  def add_citations_state_codings
#    render(:update) do |page|
#      page.insert_html :bottom, 'div_citation_list', :partial=>"shared/citation", :collection => params[:citation_ids]
#    end
#  end
#
#  def modify_matrix
#    @project = current_project
#    @otu_groups = OtuGroup.where(project_id: current_project.id)
#    @chr_groups = Morphology::ChrGroup.where(project_id: current_project.id)
#    params[:matrix_checkpoint_id] = @matrix.checkpoint.id
#    params[:conditions] = @matrix.checkpoint.id.to_s+"[matrix_checkpoint_id]"
#    params.merge!({ :include => '[creator,otu_group]',:limit => '20'})
#    @branches =  Morphology::Matrix::Checkpoint.find(params[:matrix_checkpoint_id]).morphology_matrices_otu_groups
#  end
#
#  def change_position
#    begin
#      move = params[:move]
#      Morphology::Matrix::Checkpoint.transaction do
#        @changeset = Matrix::Changeset.find_or_create_for(current_user, @matrix.address)
#        #@characters, @otus = @changeset.process_chr_otu_history( @matrix.characters, @matrix.otus)
#        if params[:type] == 'otu'
#          otu = Otu.find(params[:otu_id])
#          @changeset.items.create!(:change_type => ChangeTypes::MOVE, :old_version => otu, :move_to_prev_position=>@matrix.otus.index(otu) + 1, :move_to_next_position => process_position(move, otu, @matrix.otus))
#          #success = @matrix.matrices_otus.find_by_matrix_id_and_otu_id(params[:id], params[:otu_id]).send(move)
#        elsif params[:type] == 'chr'
#          chr = Morphology::Character.find(params[:chr_id])
#          @changeset.items.create!(:change_type => ChangeTypes::MOVE, :old_version => chr,:move_to_prev_position=>@matrix.characters.index(chr) + 1, :move_to_next_position => process_position(move, chr, @matrix.characters))
#          #success = @matrix.characters_matrices.find_by_matrix_id_and_character_id(params[:id], params[:chr_id]).send(move)
#        end
#      end
#      @otu_groups = OtuGroup.find(:all)
#      @chr_groups = Morphology::ChrGroup.find(:all)
#
#      flash[:notice] = 'Move successful.'
#    rescue RuntimeError => e
#      flash[:error] = e.message
#    rescue => e
#      flash[:error] = "Error encountered while moving.  Sorry for the inconvenience. #{e.message}"
#      log_error e
#    end
#    respond_to do |format|
#      format.html { redirect_to(modify_matrix_project_morphology_matrix_path(params[:project_id], @matrix))   }
#      format.xml  { head :ok }
#      format.js
#    end
#  end
#
#  def merge_with_parent
#    begin
#      @matrix_parent = @matrix.parent.current_virtual_matrix
#      @new_matrix_address = Morphology::Matrix::Checkpoint.merge(@matrix, @matrix_parent)
#      flash[:notice] = "Changes applied successfully"
#    rescue => e
#      flash[:notice] = "Error applying changes: #{e.message}"
#    end
#    respond_to do |format|
#      format.html { redirect_to(project_morphology_matrix_path(current_project,@matrix_parent))   }
#      format.xml  { head :ok }
#      format.js
#    end
#  end
#

#
#  def export_matrix
#    respond_to do |format|
#      format.html { redirect_to(project_morphology_matrix_path(params[:project_id],@matrix.id))  }
#      format.xml  { head :ok }
#      format.js
#    end
#  end
#
#  def show_commit_changes_notice
#    unless @matrix.changeset.items.empty?
#      case params[:notice_response]
#        when "yes" then redirect_to show_commit_changes_options_project_morphology_matrix_path   # if commit requested then start commit workflow
#        when "no"  then @parameters = session[:params_stack].pop                      # if commit not requested then return from notify action
#        when nil
#          session[:params_stack].clear
#          session[:params_stack].push(params)
#          render :show_commit_changes_notice
#        else
#          raise "unrecognized response type"
#      end
#    end
#  end
#
#  def show_commit_changes_options
#    @branch_options = [ ]
#    @branch_options << [ 'next version', 'main' ] if @matrix.branch_position == @matrix.branch.max_position
#    @branch_options << [ 'new matrix', 'new' ]
#    @changeset_id = params[:changeset_id] || Matrix::Changeset.find_or_create_for(current_user, @matrix.address).id
#
#    respond_to do |format|
#      format.js { @window_name = :commit_changes_options_window; render "shared/show_window"}
#    end
#  end
#
#  def commit_changes
#    @changeset = current_user.changesets.find(params[:commit][:changeset_id])
#    branch_option = params[:commit][:branch]
#    if branch_option == 'main'
#      new_address = @changeset.commit(:current_user => current_user.user_id)
#    elsif branch_option == 'new'
#      new_address = @changeset.commit(:new_branch => true, :current_user => current_user.user_id)
#    end
#    old_chekpoint_id = @matrix.checkpoint.id
#    #Below code inserted to copy old version entries of matrices_otu_groups for a checkpoint as a new version entries
#    @matrix = Matrix::UserMatrix.for_address_and_user_and_project(Matrix::Address.from_s(new_address), current_user, @current_project, action_name != "modify_matrix" ? { :process_codings_changes => true, :page => params[:page] || 1 } : { })
#    new_checkpoint_id = @matrix.checkpoint.id
#        @mor_otu = Morphology::Matrix::MorphologyMatricesOtuGroups.find(:all, :conditions => ["matrix_checkpoint_id = ?", old_chekpoint_id])
#         @mor_otu.each do |rec|
#            Morphology::Matrix::MorphologyMatricesOtuGroups.add_otu_group_to_matrix({:matrix_checkpoint_id => new_checkpoint_id, :color => rec.color, :otu_group_id => rec.otu_group_id, :creator_id => current_user.id , :updater_id => current_user.id })
#         end
#    if session[:params_stack].empty?
#      @destination = project_morphology_matrix_path(current_project, new_address)
#      respond_to do |format|
#        format.js { render "shared/redirect" }
#      end
#    else
#      session[:params_stack].add_to_last :id => new_address.to_s
#      session[:params_stack].add_to_last :ajax_response_top => "$('commit_changes_options_window').hide();"
#      @destination = session[:params_stack].last_location(self)
#      redirect_with_request session[:params_stack].pop
#    end
#    #TODO need to set status on failure case
#
#
#  end
#
#  def revert_change(options = {})
#    options[:single_change] = true
#    Matrix::ChangesetItem.find(params[:changeset_item_id]).revert(options)
#    flash[:notice] = "Revert was successful."
#    respond_to do |format|
#      format.html { redirect_to project_morphology_matrix_path(current_project, params[:id]) }
#    end
#  end
#
#  def revert_all_changes
#    Matrix::Changeset.find_or_create_for(current_user, Matrix::Address.from_s(params[:id])).items.each {|item| item.revert}
#    respond_to do |format|
#      format.html {  redirect_to project_morphology_matrix_path(current_project, params[:id]) }
#    end
#  end
#
#  def show_designate_submatrix
#    @matrix = Morphology::Matrix.new
##    @project = current_project
#    respond_to do |format|
#      format.html { render 'show_designate_submatrix', layout: request.xhr? ? false : 'application' }
#    end
#  end
#
#  #new merge matrices showpage
#  def show_merge_matrices
##    debugger
##    @project = current_project
#    @matrix = Morphology::Matrix.new
#    respond_to do |format|
#      format.html { render 'show_merge_matrices', layout: request.xhr? ? false : 'application' }
#    end
#  end
#
#  #old, will not be used
#  def show_merge_window
#    @project = current_project
#
#    respond_to do |format|
#      format.js
#    end
#  end
#
#  def show_designate_submatrix_window
#    @project = current_project
#    respond_to do |format|
#      format.js
#    end
#  end
#
#  def designate_submatrix
#    parent_name = params[:parent_matrix]
#    matrix_name = params[:submatrix]
#    if !parent_name.nil? || !matrix_name.nil?
#      parent_branch = current_project.branches.find_by_name(parent_name)
#      matrix_branch = current_project.branches.find_by_name(matrix_name)
#      if !parent_branch.nil? || !matrix_branch.nil?
#        if  current_user.is_manager?(current_project) || matrix_branch.creator == current_user
#          matrix_branch.parent = parent_branch
#          matrix_branch.save!
#          @message  = "Successfully designated #{matrix_name} as a submatrix of #{parent_name}. "
#        else
#          @message = "You need to be a manager of the project or owner of the #{matrix_name} matrix."
#        end
#      else
#        if parent_branch.nil? && matrix_branch.nil?
#          @message = "Neither matrix name you entered exists."
#        elsif parent_branch.nil?
#          @message = "Parent matrix doesn't exist."
#        elsif matrix_branch.nil?
#          @matrix = "Child matrix doesn't exist.'"
#        end
#      end
#    else
#      @message = "You need to make both selections."
#    end
#    respond_to do |format|
#      format.json { render json: { :message => @message, :id => current_project.id } }
#    end
#  end
#
#  def show_matrix_history
#    respond_to do |format|
#      format.js { @window_name = :matrix_history_window; render "shared/show_window" }
#    end
#  end
#
#  def merge
#    options = { }
#    params[:merge][:from_name] = params[:from_name]
#    params[:merge][:to_name] = params[:to_name]
#    #FIXME this is a kludge to allow matrices to be merged to the next version
#    # on both the from matrix and to matrix, but with from matrix still always
#    # taking precedence over to matrix when merging cells.  figure out a better
#    # way to name these matrices and have it clear which one overwrites the other
#    case params[:merge][:merge_as]
#    when 'new matrix', 'next version of with matrix'
#      from_name = params[:merge][:from_name]
#      to_name = params[:merge][:to_name]
#    when 'next version of from matrix'
#      from_name = params[:merge][:to_name]
#      to_name = params[:merge][:from_name]
#      options.merge!({ :reverse_overwrite => true })
#    else
#      raise "unsupported option for merge as"
#    end
#    if !from_name.nil? || !to_name.nil?
#      begin
#        from_branch = current_project.branches.find_by_name(from_name)
#        raise "you have provided an invalid from-matrix name" if from_branch.nil?
#        from_version = params[:merge][:from_version]
#        from_version = from_branch.max_position if from_version.nil?
#        from_address = Matrix::Address.from_branch_info(from_branch, from_version)
#        from_matrix = Morphology::Matrix.for_matrix_address(from_address)
#
#        to_branch = current_project.branches.find_by_name(to_name)
#        raise "you have provided an invalid to-matrix name" if to_branch.nil?
#        to_version = params[:merge][:to_version]
#        to_version = to_branch.max_position if to_version.nil?
#        to_address = Matrix::Address.from_branch_info(to_branch, to_version)
#        to_matrix = Morphology::Matrix.for_matrix_address(to_address)
#
#        options.merge!({ :new_branch => true }) if params[:merge][:merge_as] == 'new matrix'
#
#        new_matrix_address = Morphology::Matrix::Checkpoint.merge(from_matrix, to_matrix, options)
#        flash[:notice] = "Merge was successful."
#
#        respond_to do |format|
#          format.json { render :json => new_matrix_address.to_json() }
#  #        format.js { redirect_to project_morphology_matrix_path(current_project, new_matrix_address) }
#        end
#
#      rescue => e
#        log_error e
#        flash[:error] = "Problem encountered while merging: #{e.message}"
#
#        respond_to do |format|
#          format.html { redirect_to project_morphology_matrices_path(current_project) }
#        end
#      end
#    else
#      raise "You must choose two matrices and two versions."
#    end
#
#
#
#  end
#
#  private
#
#   def otu_groups_list
#    @otu_groups_list = @matrix.checkpoint.morphology_matrices_otu_groups
#  end
#
#  def handle_destroy_matrix(matrix)
#    Morhology::Matrix.transaction do
#      matrix.children.each { |c|
#        c.delete_matrix_data
#        c.destroy
#      }
#      matrix.destroy
#    end
#  rescue => e
#    log_error e
#    nil
#  end
#
#  def return_working_matrix
##   hack to include otu_group_id
#    if params[:otu_group_id] != ""
#      @matrix = Matrix::UserMatrix.for_address_and_user_and_project(Matrix::Address.from_s(params[:id]), current_user, @current_project, action_name != "modify_matrix" ? { :process_codings_changes => true, :page => params[:page] || 1, :group_id => params[:otu_group_id] } : { })
#    else
#      @matrix = Matrix::UserMatrix.for_address_and_user_and_project(Matrix::Address.from_s(params[:id]), current_user, @current_project, action_name != "modify_matrix" ? { :process_codings_changes => true, :page => params[:page] || 1 } : { })
#    end
#    redirect_to project_morphology_matrices_path unless @matrix
#  end
#
#  def matrix_list_attributes_and_properties
#    #@attributes_to_show = [ :name, :description, :creator ]
#    @attributes_to_show = [ :name, :description, :parent, :updater, :updated_at, :creator, :created_at  ]
#    @attribute_display_properties = {
#      :name         => {
#        :link_type => 'href',
#        :link => "project_morphology_matrix_path(#{@project.id}, object.max_address)"
#      },
#      :description  => { :width => '200px', :truncate => 150 },
#      :creator => { :label => 'Owner', :display_attribute => 'full_name' },
#      :parent => {
#        :label => 'Submatrix of', :display_attribute => 'name', :link_type => 'href',
#        :link => "project_morphology_matrix_path(#{@project.id}, object.parent.max_branch_item.item.to_param)"
#      },
#      :updater => { :label => 'Last Updater', :display_attribute => 'full_name'},
#      :created_at => { :label => 'Created On' },
#      :updated_at => { :label => 'Last Update' }
#    }
#  end
#
#  def get_tooltips(chr_id_array)
#    tooltips = Morphology::Matrix::Checkpoint.get_states_for_tooltip(chr_id_array)
#    tooltips.to_json
#  end
#
#  # retrieves the most recent version of a state coding given a changeset and the
#  # character and otu for the position
#
#
#  def process_position(move, obj, obj_arr)
#    start_position = obj_arr.index(obj) + 1
#    last_index = obj_arr.size
#    case move.upcase
#    when "MOVE_LOWER"
#      raise "Cannot Move Any Lower" if start_position == last_index
#      return start_position + 1
#    when "MOVE_HIGHER"
#      raise "Cannot Move Any Higher" if start_position == 1
#      return start_position - 1
#    when "MOVE_TO_TOP"
#      raise "Cannot Move Any Higher" if start_position == 1
#      return 1
#    when "MOVE_TO_BOTTOM"
#      raise "Cannot Move Any Lower" if start_position == last_index
#      return last_index
#    end
#  end
#
#  def project_manager_or_owner?(branch)
#    has_project_role?('manager') || branch.creator == current_user
#  end
#
#  #builds display message for showing the result of character_updateand otu_update actions
#  #  def build_display_message_for_chr_otu_update(objs_added, objs_not_added, type = "")
#  #    display_mess = ""
#  #    display_mess = objs_added.join(',') + ' ' + type + ' Added Successfully' if objs_added.size>0
#  #    display_mess += objs_not_added.join(',') + ' ' + type + ' not added as they are already part of the matrix.' if objs_not_added.size > 0
#  #    display_mess
#  #  end
#
#  def set_last_matrix_page
#    session[:matrix_page] = params[:page]
#  end
#
#end
#
#
