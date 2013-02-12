class Morphology::Matrix::StateCodingsController < ApplicationController
  def show
    @cell = @current_project.state_codings.find(params[:id], :include => [ :otu, { :character => :chr_states } ])
    @path, @method = [ project_matrix_state_coding_path, :put]
    respond_to do |format|
      format.js { render :show, :layout => false }
      format.html { render :hello }
    end
  end

  def update
    if !params[:cell] && params[:state]
      params[:coding][:codings] = params[:state].keys.collect{ |id_or_sym|
        case id_or_sym
        when 'dash' then '-'
        when 'question_mark' then '?'
        else Morphology::ChrState.find(id_or_sym).state
        end
      }.sort.join(" ")
    end
    Matrix::Changeset.transaction do
      old_cell = @current_project.state_codings.find(params[:id])
      @new_cell = old_cell.create_clone( (params[:cell] || params[:coding]).merge(:created_at => nil, :creator_id => nil, :matrix_id => nil) )
      @changeset = Matrix::Changeset.find_or_create_for(@current_user, Matrix::Address.from_s(params[:matrix_id]))
      @changeset.items.create!(:change_type => 'modify', :old_version => old_cell, :new_version => @new_cell )
    end
    respond_to do |format|
      format.js   {
        render :json => {
          :changes_list => render_to_string(:partial => '/shared/panes/versioning_pane_changes_list', :object => @changeset),
          :new_cell_id => @new_cell.id
        }
      }
    end
  end

  def new
    @cell = Morphology::StateCoding.new( :character_id => params[:character_id], :otu_id => params[:otu_id] )
    @path, @method = [ project_matrix_state_codings_path, :post ]
    respond_to do |format|
      format.js { render :new, layout: false, content_type: 'text/html' }
    end
  end

  def create
    if !params[:cell] && params[:state]
      params[:coding][:codings] = params[:state].keys.collect{ |id_or_sym|
        case id_or_sym
        when 'dash' then '-'
        when 'question_mark' then '?'
        else Morphology::ChrState.find(id_or_sym).state
        end
      }.sort.join(" ")
    end
    params[:cell][:project_id] = params[:project_id]
    Matrix::Changeset.transaction do
      @new_cell = Morphology::StateCoding.create!(params[:cell] || params[:coding]) # quick edit mode and standard mode
      fail "matrix_id should not be set" unless @new_cell.matrix_id.nil?
      @changeset = Matrix::Changeset.find_or_create_for(@current_user, Matrix::Address.from_s(params[:matrix_id]))
      @changeset.items.create!(:change_type => 'modify', :old_version => nil, :new_version => @new_cell )
    end
    respond_to do |format|
      format.js   {
        render :json => {
          :changes_list => render_to_string(:partial => '/shared/panes/versioning_pane_changes_list', :object => @changeset),
          :new_cell_id => @new_cell.id
        }
      }
    end
  end
end
