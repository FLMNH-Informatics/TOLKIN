class Molecular::ImportFastaSeqsController < ApplicationController
  before_filter :requires_selected_project

  def new
    @taxon = Taxon.new
    @seq = current_project.sequences.new
    @project = current_project
    respond_to {|format| format.html { render 'new', layout: request.xhr? ? false : 'application' } }
  end

  def create
    @marker_names = []
    @marker_names = params[:marker_names] unless params[:marker_names].blank?
    @marker_names.push(params[:new_marker]) unless params[:new_marker].blank?
    unless params[:molecular_insd_seq][:taxon_name].empty?
      @taxon = passkey.unlock(Taxon).where('taxon_id = ?', params[:molecular_insd_seq][:taxon_taxon_id]).first || Taxon.create!(:name => params[:molecular_insd_seq][:taxon_name])
    end
    filename = Molecular::FastaFilename.create!(:filename => params[:seq][:uploaded_data].original_filename, :upload_date => Time.now, :project_id => current_project.project_id)
    uploaded_data = params[:seq][:uploaded_data].read
    @project = current_project
    fasta_seqs = uploaded_data.split('>').collect{|fs| Molecular::ImportFastaSeq.from_filestring(fs) unless fs.blank? }.compact
    @tolkin_seqs = fasta_seqs.collect{ |fastaseq| Molecular::Insd::Seq.from_biofasta(fastaseq, current_project, filename) }
    unless @marker_names.empty?
      @tolkin_seqs.each do |seq|
        if seq.markers.empty?
          @marker_names.each do |marker_name|
            marker = Molecular::Marker.where('project_id = ? and name = ?', @project.project_id, marker_name).first || Molecular::Marker.create!(:name => marker_name, :project_id => @project.project_id)
            seq.markers << marker
          end
        end
        if seq.taxon.nil? && @taxon
          seq.taxon = @taxon
          seq.organism = @taxon.name
        end
        seq.save!
      end
    end
    respond_to { |format|
      format.html { render :text => {"fasta_filename_id" => filename.id, "count" => @tolkin_seqs.size }.to_json }
    }
  end
end