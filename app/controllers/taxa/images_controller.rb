class Taxa::ImagesController < ImagesController
  def destroy
    taxon = passkey.unlock(Taxon).find(params[:taxon_id])
    if(taxon.update_authorized?)
      taxon.taxa_images.find_by_image_id(params[:id]).destroy
    end
    respond_to do |format|
      format.json { head :ok }
    end
  end
end