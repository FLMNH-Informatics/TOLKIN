class TaggingsController < ApplicationController
  include AuthenticatedSystem
  
  before_filter :requires_logged_in
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method=>:delete,
         :redirect_to => :tags_path
  
  def list
    
  end
  
  def show
    
  end
  
  def new
    
  end
  
  def edit
    
  end
  
  def update
  end
  
  def destroy
    tagging = Tagging.find(params[:id])
    tagging.destroy
    flash[:notice] = "Successfully Deleted the tagged object"
    if !Tag.find(params[:tag_id]).taggings.empty?
      redirect_to tag_path(params[:tag_id])
    else
      redirect_to tags_path()
    end
  end
end
