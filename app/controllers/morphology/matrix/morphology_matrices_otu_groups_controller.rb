class Morphology::Matrix::MorphologyMatricesOtuGroupsController < ApplicationController

  include Restful::Responder
  before_filter :requires_selected_project


  def update
    debugger
    Morphology::Matrix::MorphologyMatricesOtuGroups.update_color(params[:id].to_i,params[:morphologymatricesotugroup][:color])
    respond_to do |format|
      format.html { redirect_to(modifymatrix_path(params[:project_id], params[:matrix_id])) }
      format.xml  { head :ok }
      format.js   { head :ok }
    end
  end

  def show
    
  end

  def destroy_all
    @matrix = Matrix::UserMatrix.for_address_and_user_and_project(Matrix::Address.from_s(params[:matrix_id]), current_user, @current_project, action_name != "modify_matrix" ? { :process_codings_changes => true, :page => params[:page] || 1 } : { })
    params[:matrix_checkpoint_id] = @matrix.checkpoint.id
    params[:conditions].gsub!(/[0-9\-]+\[matrix_checkpoint_id\]/ , @matrix.checkpoint.id.to_s+'[matrix_checkpoint_id]')
    params.merge!({ :include => '[creator,otu_group]',:limit => '20'})
    @collection = Morphology::Matrix::Checkpoint.find(params[:matrix_checkpoint_id]).morphology_matrices_otu_groups.collection
    @collection.load(params)
    @collection.entries.each do |record|
        Morphology::Matrix::MorphologyMatricesOtuGroups.destroy_all(:id => record.id)
    end

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to(:back)  }
      format.js   { head :ok }
    end
  end

  def index
    @matrix = Matrix::UserMatrix.for_address_and_user_and_project(Matrix::Address.from_s(params[:matrix_id]), current_user, @current_project, action_name != "modify_matrix" ? { :process_codings_changes => true, :page => params[:page] || 1 } : { })
    params[:matrix_checkpoint_id] = @matrix.checkpoint.id
    params[:conditions].gsub!(/[0-9\-]+/ , @matrix.checkpoint.id.to_s)
    params.merge!({ :include => '[creator,otu_group]',:limit => '20'})
    #respond_to_index_request_searchlogic(Molecular::Matrix::MolecularMatricesOtuGroups.find(:all , :conditions => ['matrix_checkpoint_id = ?',params[:matrix_checkpoint_id]]))
    respond_to_index_request_searchlogic(Morphology::Matrix::Checkpoint.find(params[:matrix_checkpoint_id]).morphology_matrices_otu_groups)
  end
end
