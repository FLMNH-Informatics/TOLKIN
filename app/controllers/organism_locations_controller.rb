# To change this template, choose Tools | Templates
# and open the template in the editor.

class OrganismLocationsController
  include Restful::Responder
  def index
    respond_to_index_request_searchlogic(OrganismLocation)
  end
end
