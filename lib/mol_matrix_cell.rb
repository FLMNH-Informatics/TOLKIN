module MolMatrixCell
  
  GYMNOSPERM_STATUS_TO_SUBCLASS_CONVERT = {
    :'DNA needed'         => 'a',
    :'Tissue unavailable' => 'c',
    :'In process'         => 'd',
    :'Submitted'          => 'b',
    :'Finished-Sanger'    => 'e',
    :'Finished-Solexa'    => 'f',
    :'Incomplete'         => 'a',
    :''                   => 'a'
  }
  STANDARD_STATUS_TO_SUBCLASS_CONVERT = {
    :'Incomplete' => 'a',
    :'Complete'   => 'b',
    :'Problem'    => 'c',
    :'Tentative'  => 'd',
    :''           => 'a'
  }
  
  def subclass_for_status status
    status ||= @current_project.name == 'Gymnosperm ATOL' ? 'DNA needed' : 'Incomplete'
    convert  = @current_project.name == 'Gymnosperm ATOL' ?
      GYMNOSPERM_STATUS_TO_SUBCLASS_CONVERT :
      STANDARD_STATUS_TO_SUBCLASS_CONVERT
    convert[status.to_sym]
  end

  def otu otu_id
    @otu_id = otu_id
  end

  def marker marker_id
    @marker_id = marker_id
  end

  def cell
    @matrix.nil? ? @cell : @matrix.cells.fetch(@marker_id, @otu_id)
    #not using a two-dim array right now so simply going to use where
    #@matrix.nil? ? @cell : @cells.where("marker_id = ? and otu_id = ?", @marker_id, @otu_id).first
  end

  def genbank_address
    seq = Molecular::Insd::Seq.where('pk = ?', cell.primary_sequence_id).first
    locus = seq.locus if seq.locus and seq.locus != ''
    unless cell.sequences.empty?
      %(http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=nucleotide&cmd=search&term=#{locus}) if locus
    end
  end

  def genbank_image_link
    %(<a target='_blank' href='#{genbank_address}' alt='gb'>#{respond_to?("image_tag") ? image_tag('genbank.gif', :size => "11x11") : "<img width='11' height='11' src='/images/genbank.gif' alt='Genbank'>"}</a>)
  end

  def mol_matrix_cell otu_id, marker_id
    otu otu_id
    marker marker_id
    cell_class = "bt"
    cell_status = cell.status_text ? cell.status_text : "Incomplete"
    #cell_status = Molecular::Matrix::Cell::Status.where('id = ?', cell.try(:status_id)).first.try(:name)
    cell_class << " #{subclass_for_status(cell_status)}"
    link_text = cell.try(:responsible_user).try(:initials)
    link_text = cell.try(:status).try(:name) || "----" if link_text.blank?
    #debugger unless cell.nil?
    seq_icon = (cell.try(:primary_sequence_id) && !cell.sequences.empty?) ? genbank_image_link : "" unless !cell.primary_sequence || cell.primary_sequence.locus == '' || cell.primary_sequence.locus.nil? || cell.primary_sequence.nil?
    id = "c_#{otu_id}_#{marker_id}"
    extra_attrs = cell ? "data-cell-id='#{cell.id}'" : ""
    seq_count = cell ? cell.try(:sequences).try(:count) : ""

    %(<td class="#{cell_class}" id="#{id}" #{extra_attrs}><div class="cell_div">#{link_text} #{seq_icon}<div class="seq_count">#{seq_count unless seq_count == 0}</div><div class="cell_checkbox"></div></div></td>)
  end
end