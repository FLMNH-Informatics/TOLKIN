class FiltersController < ApplicationController
# before_filter :requires_selected_project
#  before_filter :requires_project_guest, :only => [ :index, :list, :show ]
#  before_filter :requires_project_updater, :only => [ :new, :create, :edit, :update, :update_collection, :update_others ]
#  before_filter :requires_project_manager, :only => [ :destroy, :delete_selected ]
  include TaxaHelper
  def index

    filters = params[:model_name].sub(/^Models::/, '').constantize.try(:get_filters)
    filters["namestatus_id"]["input"] = status_select if filters["namestatus_id"]
    respond_to do |format|
      format.json {  render :json => { :filters => filters }, :content_type => 'application/json' }
    end
  end
end
