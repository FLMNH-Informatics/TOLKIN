class LengthUnitsController < ApplicationController
  include Restful::Responder
  def index
    respond_to_index_request_searchlogic(LengthUnit)
  end
end
