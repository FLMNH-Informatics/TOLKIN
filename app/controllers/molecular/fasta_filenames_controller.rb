class Molecular::FastaFilenamesController < ApplicationController
  def show
    @fasta_filename = Molecular::FastaFilename.where('id = ?', params['id']).first
    ids = Molecular::Insd::Seq.for_fasta_filename(@fasta_filename.id).collect{ |seq| seq.id }
    @fasta_filename.destroy if ids.length == 0
    respond_to do |format|
      format.json { render :json => { :ids => ids } }
      format.html { render 'show', layout: request.xhr? ? false : 'application' }
    end
  end
end
