class StatusesController < ApplicationController
  include Restful::Responder
  def index
    respond_to_index_request_searchlogic(@current_project.mol_matrix_cell_statuses)
  end

end
