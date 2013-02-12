#require 'bio'

class Molecular::Resources::Ncbi::EUtilsController < ApplicationController
  def esearch
    @match_ids = Bio::NCBI::REST::ESearch.nucleotide(params[:term])[:ids]
    respond_to do |format|
      format.json { render :json => @match_ids }
    end
  end

  def esearch_esummary
    esearch_results = Molecular::Resources::Ncbi::EUtils.esearch('nucleotide', params[:search_query], :retmax => 20)
    @count = esearch_results[:count]
    @summaries = Molecular::Resources::Ncbi::EUtils.esummary esearch_results[:ids]
    respond_to do |format|
      format.json { render :json => { :count => @count, :summaries => @summaries } }
    end
  end

  def epost_efetch
    epost_results = Molecular::Resources::Ncbi::EUtils.epost(params[:genbankid])
    @genbankrecord = Molecular::Resources::Ncbi::EUtils.efetch(epost_results[:webenv], epost_results[:querykey])
    respond_to do |format|
      format.json { render :json => { :genbankrecord => @genbankrecord } }
    end
  end

  def check_identifier
    unless params[:term].blank?
      match_ids = Bio::NCBI::REST::ESearch.nucleotide(params[:term] + "[ACCN]")
      if match_ids.empty?
        @gi = Molecular::Resources::Ncbi::EUtils.esummary(params[:term]).empty? ? nil : params[:term]
      else
        @gi = match_ids[0]
      end
    end

    if @gi
      respond_to do |format|
        format.json { render :text => @gi, :status => :ok }
      end
    else
      respond_to do |format|
        format.json { render :text => "", :status => :no_content }
      end
    end
  end
end
