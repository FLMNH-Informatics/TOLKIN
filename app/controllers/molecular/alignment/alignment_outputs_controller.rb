class Molecular::Alignment::AlignmentOutputsController < ApplicationController
  include Restful::Responder
  include Bio

  def new
    @alignment = Molecular::Alignment.where('id = ?', params[:alignment_id]).first
    output = @alignment.alignment_outputs.new({
                                       :alignment_type => params['type'],
                                       :alignment_text => params['type'] == 'fasta' ? @alignment.to_fasta : @alignment.output_alignment(params['type'].to_sym)
                                       #:alignment_text => params['type'] == 'fasta' ? @alignment.to_fasta : @alignment.to_bio_alignment.output(params['type'].to_sym)
                                     })
    output.save
    respond_to {|format| format.json { render :json => { 'alignment_output' => output } } }
  end
end