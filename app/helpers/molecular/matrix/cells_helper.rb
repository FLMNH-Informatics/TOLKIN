module Molecular::Matrix::CellsHelper

  def otu_name
    @cell.new_record? ? @otu.name : @cell.otu.name
  end

  def marker_name
    @cell.new_record? ? @marker.name : @cell.marker.name
  end

  def responsible_user_name
    interact_mode == "browse" || params[:action] == "show_cell_info" ? ("&nbsp;".html_safe + @cell.responsible_user.name unless @cell.responsible_user.nil?) : responsible_user_select
  end

  def current_status
    interact_mode == "browse" || params[:action] == "show_cell_info" ? ("&nbsp;".html_safe + @cell.status.name unless @cell.status.nil?) : current_status_select
  end

  def notes
    interact_mode == "browse" || params[:action] == "show_cell_info" ? notes_field : notes_field(true)
  end

  def viewport_window
    @viewport_window ||= General::Window.new
  end

  def current_status_select
    select("cell", "status_id", Molecular::Matrix::Cell::Status.for_project(current_project).collect { |s| [s.name, s.id] } )
  end

  def responsible_user_select
    select("cell", "responsible_user_id", User.with_roles_in_project(current_project).collect { |u| [u.name, u.user_id] }, {:include_blank => "None"} )
  end

  def notes_field enabled = false
    enabled ?
      %(<textarea id="cell_notes" name="cell[notes]" rows="5" cols="40">#{@cell.notes}</textarea>) :
      %(<textarea disabled="true" id="cell_notes" name="cell[notes]" rows="5" cols="40">#{@cell.notes}</textarea>)
  end

  def sequence_field
      %(<textarea disabled="true" id="cell_primary_sequence" rows="5" cols="40">#{@primary_sequence.sequence.capitalize if @primary_sequence}</textarea>)
  end

  def sequence_controls
    interact_mode == "browse" || params[:action] == "show_cell_info" ? '' : %(<span class="pagetitletext">(<a id="remove_seq" href="#" tool="remove">Remove</a>) (<a id="make_primary" href="#" tool="primary">Set as primary</a>)</span>)
  end

  def sequence_table_headers
    return %(<tr>
              <th class="h"></th>
              <th style="width:38px;" class="h">Info</th>
              <th class="h">Organism</th>
              <th class="h">Status</th>
            </tr>)
  end

  def sequence_rows
    rows = '<tbody id="cell_sequences_list">'
    @cell.sequences.each do |seq|
      rows += %(
        <tr id="tr_sequence_#{seq.id}" class="#{cycle('body-odd', 'body-even')}" data-seq-id="#{seq.id}" data-tooltip="#{seq.sequence}" title="#{seq.sequence.tooltipify}">
          <td class="b tdseq"><input type="checkbox" id="sequence_##{seq.id}" name="cell_sequences[]" value="#{seq.id}" /></td>
          <td style="width:38px;" class="b tdseq"><a target="_blank" href="http://www.ncbi.nlm.nih.gov/nuccore/#{seq.locus}"><img class="gb_hov" src="/images/genbank.gif" alt="[GB]"></a>&nbsp;<a class='display_sequence'><img class="gb_hov display_sequence" src="/images/icon-zoom-14-smudged.gif" alt="[?]"></a></td>
          <td class="b tdseq">#{seq.organism}</td>
          <td class="b tdseq">#{primary_seq(seq)}</td>
        </tr>
      )
    end
    return rows + '</tbody>'
  end

  def primary_seq seq
    return "primary" if seq.id == @cell[:primary_sequence_id]
  end

  def seqs_catalog
    Molecular::Insd::Seqs::SeqCatalog.new({
      collection: @seqs,
      context: self,
      parent: viewport_window,
      can_publify: false
      }).render_to_string
  end

end
