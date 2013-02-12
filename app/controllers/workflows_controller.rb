class WorkflowsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.js { render :partial => 'index_contents' }
    end
  end

  def show
    respond_to do |format|
      format.js { render :partial => 'workflow_details' }
    end
  end

  def new
    respond_to do |format|
      format.js { render :partial => 'new' }
    end
  end
end
