class Molecular::AlignmentsController < ApplicationController
  include Restful::Responder
  include Bio

  before_filter :file_import, only: :create

  def index
    query_params_provided? ||
      params.merge!(
        select: [ :id, :name, :description, :creator_id ],
        #include: { creator: { select: [ 'user_id', 'label' ]}},
        limit: 20,
        order: [ :name ]
      )
    super current_project.alignments
  end
  
  def new
    respond_to do |format|
      format.html { render :html => 'new', :layout => false }
      #format.xml  { render :xml => @matrix }
      format.js
    end
  end

  def show
    @alignment = Molecular::Alignment.includes(:alignment_outputs).where('id = ?', params[:id]).first
    respond_to { |format| format.html { render :html => 'show', :layout => request.xhr? ? false : true } }
  end

  def update_alignment_info
    alignment = Molecular::Alignment.where('id = ?', params[:id]).first
    debugger
    if alignment.update_attributes(params[:alignment])
      respond_to { |format| format.json { render :json => { :alignment => alignment.to_json } } }
    else
      respond_to { |format| format.json { render :json => { :error => %(Couldn't update.) } } }
    end
  end

  def create
    #not in use right now
    #all alignments should be created either via a matrix or via the sequences section
    #respond_to_create_request this is not the responder method to use either
  end

  def remove_sequence
    @alignment = Molecular::Alignment.where('id = ?', params[:id]).first
    @alignment.remove_seq(params[:seq_id])
    respond_to { |format| format.html { render :html => 'show', :layout => false } }
  end

  def retrieve_alignment_text
    @alignment = Molecular::Alignment.includes(:alignment_outputs).where('id = ?', params[:id]).first
    respond_to { |format| format.json { render :json => { :alignments_hash => @alignment.alignments_hash.to_json } } }
  end

  def export
    @alignment = Molecular::Alignment.where('id = ?', params[:id]).first
    output = @alignment.alignment_outputs.where('alignment_type = ?', params[:type]).first.alignment_text
    fpath = "#{RAILS_ROOT}/public/files/alignment" + params[:type].to_s.capitalize + '.' + params[:type].to_s
    File.open(fpath, 'w'){|f| f.write(output) }
    send_file(fpath, :disposition => 'attachment')
  end

  def export_fasta
    fpath = "#{RAILS_ROOT}/public/files/alignmentFasta.fsa"
    @alignment = Molecular::Alignment.where('id = ?', params[:id]).first
    filename = 'alignment_' + DateTime.now.to_s.delete('-:T')
    File.open(fpath, 'w'){ |f| f.write(@alignment.to_fasta) }
    send_file(fpath, :disposition => 'attachment')
  end

  #def export_clustal
  #  fpath = "#{RAILS_ROOT}/public/files/alignmentCLUSTAL.clustalw"
  #  @alignment = Molecular::Alignment.where('id = ?', params[:id]).first
  #  File.open(fpath, 'w'){ |f| f.write(@alignment.to_bio_alignment.output(:clustal))}
  #  send_file(fpath, :disposition => 'attachment')
  #end

  def delete_selected
    #FIXME without the appropriate foreign key actions set I can leave orphans in the database
    #todo look into above note, i dont' think it applies right now
    super current_project.alignments
  end
  
  def update
    respond_to_update_request
  end

  private

  def file_import
    if(params[:alignment][:file])
      debugger
      #params[:alignment][:seq] = params[:alignment][:file].read
      #params[:alignment].delete(:file)
    end
  end
end
