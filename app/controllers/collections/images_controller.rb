class Collections::ImagesController < ImagesController
  def destroy
    collection = @current_project.collections.find(params[:collection_id])
    if(@current_user.can_edit?(collection))
      collection.collections_images.find_by_image_id(params[:id]).destroy
    end
    respond_to do |format|
      format.json { head :ok }
    end
  end
end