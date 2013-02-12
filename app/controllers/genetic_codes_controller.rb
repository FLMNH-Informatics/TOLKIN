# To change this template, choose Tools | Templates
# and open the template in the editor.

class GeneticCodesController < ApplicationController
  include Restful::Responder
  def index
    respond_to_index_request_searchlogic(GeneticCode)
  end
end
