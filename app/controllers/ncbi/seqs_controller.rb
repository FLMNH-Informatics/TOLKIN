require 'timeout'

class Molecular::Resources::NcbiSeqsController < ApplicationController
  def index
    esearch_results = Molecular::Resources::Ncbi::EUtils.esearch params
    esummary_results = Molecular::Resources::Ncbi::EUtils.esummary(esearch_results[:ids])
    respond_to do |format|
      format.json { render json: { count: esearch_results[:count], requested: esummary_results } }
    end
  end
end