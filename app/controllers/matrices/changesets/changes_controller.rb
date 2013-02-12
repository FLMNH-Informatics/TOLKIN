class Matrices::Changesets::ChangesController < ApplicationController
  include Restful::Responder

  def index
    respond_to_index_request_searchlogic (current_project.changesets.find(params[:changeset_id]).changes)
  end

  def revert
    @changeset = current_user.changesets.find(params[:changeset_id])
    @total_reverted = @changeset.changes.find(params[:id]).revert
    respond_to do |format|
      format.js  { render :partial => '/shared/panes/versioning_pane_changes_list', :object => @changeset }
      format.xml { head   :ok }
    end
  end

  def revert_all
    @total_reverted = current_user.changesets.find(params[:changeset_id]).changes.first.revert
    respond_to do |format|
      format.js  { render :text => @total_reverted, :status => :ok }
      format.xml { head :ok }
    end
  end
end
