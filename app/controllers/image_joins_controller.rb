class ImageJoinsController < ApplicationController
  def destroy
    image_join = ImageJoin.find(params[:id])
    fail "don't have permission" unless current_user.can_edit?(image_join.object)
    image_join.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :ok }
    end
  end
end