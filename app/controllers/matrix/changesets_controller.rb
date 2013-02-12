class Matrix::ChangesetsController < ApplicationController
  def show
    @changeset = current_project.changesets.find(params[:id],
      :joins => 'LEFT JOIN changeset_items ci1 ON ci1.changeset_id = changesets.id AND ci1.parent_id IS NULL
                 LEFT JOIN changeset_items ci2 ON ci2.parent_id = ci1.id')
    respond_to do |format|
      format.js  { render :json => @changeset.to_json(:include => { :items => { :include => :subchanges } }) }
      format.xml { render :xml => @changeset }
    end
  end
end
