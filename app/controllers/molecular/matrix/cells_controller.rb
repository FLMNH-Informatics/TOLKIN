require 'bio'

class Molecular::Matrix::CellsController < ApplicationController
  include Restful::Responder
  include SeqSearch::MolMatrixGenbankSearch
  include MolMatrixCell


  #before_filter :retrieve_working_matrix, only: [ :create ]


#  before_filter :retrieve_cell_for_id, :except => :new, :create

  def new_cell
    @cell = Molecular::Matrix::Cell.new({ :otu_id => params[:otu_id],
                                          :marker_id => params[:marker_id],
                                          :timeline_id => params[:matrix_id],
                                          :create_date => DateTime.now.utc,
                                          :is_active => true
                                         })
    @cell.save
    cell_id, cell_markup = html_cell_id(@cell), mol_matrix_cell(@cell.otu_id, @cell.marker_id)
    respond_to do |format|
      format.json { render :json => {htmlid: cell_id, htmlcell: cell_markup, cell: @cell} }
    end
  end

  def create
    tolkin_seqs = params[:tolkin_seqs].split(',')
    gb_seqs =     params[:gb_seqs]
    Molecular::Matrix::Cell.transaction do
      @cell = Molecular::Matrix::Cell.new(params[:cell])
      @cell.make_primary(params[:seq][:primary].blank? ?  nil : params[:seq][:primary])
      if gb_seqs && gb_seqs != [""]
        gb_seqs.each do |sequence|
          seq = JSON.parse(sequence)
          check_for_existence = current_project.sequences.where('sequence = ? and locus = ? and organism = ? and definition = ?', seq['sequence'], seq['locus'], seq['organism'], seq['definition'])
          if check_for_existence.empty?
            taxa = passkey.unlock(Taxon)
            existing = taxa.where('name = ?', seq['organism'])
            taxon = existing.first || taxa.create!(:name => seq['organism'])
            new_seq = make_seq(seq)
            markers = seq['markers'].collect{|m| process_marker(m)}
            new_seq.taxon = taxon
            new_seq.sequence = nil if new_seq.sequence == 'genome'
            new_seq.save!
            markers.each { |mrkr| mrkr.each { |k,v| new_seq.seq_markers.create(:marker => k, :position => v) } }
            @cell.sequences << new_seq unless @cell.sequences.include?(new_seq)
          else
            @cell.sequences << check_for_existence.first unless @cell.sequences.include?(check_for_existence.first)
          end
        end
      end
      if tolkin_seqs
        tolkin_seqs.each do |seq|
          sequence = Molecular::Insd::Seq.find(seq)
          @cell.sequences << sequence unless @cell.sequences.include?(sequence)
        end
      end
      @cell.save!
    end
    @cell.reload
    cell_id = html_cell_id(@cell)
    cell_markup = mol_matrix_cell(@cell.otu_id, @cell.marker_id)
    respond_to do |format|
      format.json { render :json => {htmlid: cell_id, htmlcell: cell_markup, cell: @cell} }
    end
  end

  def new
    @project = current_project
    @timeline = Molecular::Matrix::Timeline.find(params[:matrix_id])
    @marker = Molecular::Marker.find(params[:markerId])
    @otu = Otu.find(params[:otuId])
    @seqs = Molecular::Insd::Seq.joins(:markers).where({:markers => [:id => @marker ? @marker.id : @cell.marker.id]}).limit(10)
    super @timeline.cells
  end

  def get_cell_info
    validate_text_params && parse_params
    @cell = Molecular::Matrix::Cell.includes(:sequences, :primary_sequence).find(params[:id])
    @primary_sequence = @cell.primary_sequence || Molecular::Insd::Seq.find(@cell.primary_sequence_id) if @cell.primary_sequence_id
    params.merge!(@cell.attributes)
  end

  def show_cell
    get_cell_info
    @seqs = Molecular::Insd::Seq.joins(:markers).where({:markers => [:id => @marker ? @marker.id : @cell.marker.id]}).limit(10)
    respond_to do |format|
      format.html { render 'show_cell', layout: request.xhr? ? false : 'application' }
      format.json { render :json => @cell.to_json() }
    end
  end

  def show_cell_info
    get_cell_info
    respond_to do |format|
      format.html { render 'show_cell_info', layout: request.xhr? ? false : 'application' }
      format.json { render :json => @cell.to_json() }
    end
  end

  #def remove_seqs cell, ids
  #  ids.each do |id|
  #    seq = Molecular::Insd::Seq.find(id)
  #    cell.sequences.delete(seq)
  #    cell[:primary_sequence_id] = nil if cell[:primary_sequence_id].to_s == id
  #    cell.save
  #  end
  #end
  #
  #def make_primary cell, id
  #  cell[:primary_sequence_id] = id
  #end

  def html_cell_id cell
    %(c_#{cell.otu_id}_#{cell.marker_id})
  end

  def update_cell_data
    Molecular::Matrix::Cell.transaction do
      params[:cell].delete(:matrix_id)
      remove = params[:seq][:removed].split(',')
      tolkin_seqs = params[:tolkin_seqs].split(',')
      gb_seqs =     params[:gb_seqs]
      old_cell = Molecular::Matrix::Cell.find(params[:id])
      @cell = Molecular::Matrix::Cell.find(params[:id]).overwrite
      remove.each{|id| @cell.remove_seq(Molecular::Insd::Seq.find(id))}
      @cell.update_attributes!(params[:cell])
      @cell.make_primary(params[:seq][:primary].blank? ? (old_cell.primary_sequence ? old_cell.primary_sequence.id : nil) : params[:seq][:primary])
      if gb_seqs && gb_seqs != [""]
        gb_seqs.each do |sequence|
          seq = JSON.parse(sequence)
          check_for_existence = current_project.sequences.where('sequence = ? and locus = ? and organism = ? and definition = ?', seq['sequence'], seq['locus'], seq['organism'], seq['definition'])
          if check_for_existence.empty?
            taxa = passkey.unlock(Taxon)
            existing = taxa.where('name = ?', seq['organism'])
            taxon = existing.first || taxa.create!(:name => seq['organism'])
            new_seq = make_seq(seq)
            markers = seq['markers'].collect{|m| process_marker(m)}
            new_seq.taxon = taxon
            new_seq.sequence = nil if new_seq.sequence == 'genome'
            new_seq.save!
            markers.each { |mrkr| mrkr.each { |k,v| new_seq.seq_markers.create(:marker => k, :position => v) } }
            @cell.sequences << new_seq unless @cell.sequences.include?(new_seq)
          else
            @cell.sequences << check_for_existence.first unless @cell.sequences.include?(check_for_existence.first)
          end
        end
      end
      if tolkin_seqs
        tolkin_seqs.each do |seq|
          sequence = Molecular::Insd::Seq.find(seq)
          @cell.sequences << sequence unless @cell.sequences.include?(sequence)
        end
      end
      @cell.save!
    end
    @cell.reload
    cell_id = html_cell_id(@cell)
    cell_markup = mol_matrix_cell(@cell.otu_id, @cell.marker_id)
    respond_to do |format|
      format.json { render :json => {htmlid: cell_id, htmlcell: cell_markup, cell: @cell} }
    end
  end

  def show_search_genbank
    @search_query = "#{@cell.marker} #{@cell.otu}"
    respond_to do |format|
      format.js { render "shared/show_window", :locals => { :window_name => "search_genbank_window" } }
    end
  end

  def search_genbank
    @match_ids = Bio::NCBI::REST::ESearch.nucleotide(params[:search_query])
    @summaries = Molecular::Resources::Ncbi::EUtils.esummary @match_ids

    respond_to do |format|
      format.json { render :json => @summaries}
    end
  end
end
