module Molecular::AlignmentsHelper
  require 'bio'
  
  def alignments_catalog
    Molecular::Alignments::Catalog.new({
        collection: @alignments,
        context: self,
        parent: content_frame
      }).render_to_string
    #    catalog('viewport_content_frame_molecular_alignment_catalog', @requested, [
    #        { :attribute => "name", :width => 250 },
    #        { :attribute => "creator.label", :label => 'Owner', :width => 150 }
    #      ], :count => @count
    #    )
  end


  def alignment_name
    interact_mode == "browse" ? @alignment.name : text_field(:alignment, :name)
  end

  def alignment_description
    interact_mode == "browse" ? @alignment.description.to_s : text_area(:alignment, :description, :size => "90x6")
  end

  def save_alignment
    interact_mode == "browse" ? '' : ''
  end

  #def alignment_text
  #  #new_align = Bio::Alignment::OriginalAlignment.new()
  #  #@alignment.sequences.each{|s| new_align.add_seq(s.sequence, s.organism + "_" + s.pk.to_s) }
  #  #interact_mode == "browse" ? '<pre>' + new_align.output(:clustal) + '</pre>' : '<pre>' + new_align.output(:clustal) + '</pre>'
  #  interact_mode == "browse" ? '<pre>' + @alignment.to_bio_alignment.output(:clustal) + '</pre>' : '<pre>' + @alignment.to_bio_alignment.output(:clustal) + '</pre>'
  #end

  def alignment_display type
    case type
      when 'clustal'

      when 'molphy'

      when 'msf'

      when 'phylip'

      when 'phylipnon'

      when 'fasta'
        
    end
  end

  def alignment_button type
    @alignment.output(type) ? %(<a href="#" class="alignment_tab" id="view_#{type.to_s}">#{type.capitalize}</a>) : %(<input type="button" value="#{type=="fasta" ? ("Generate Fasta") : ("Generate " + type.capitalize + " alignment")}">)
  end

  def sequence_table_headers
    return %( <tr>
                <th class="h"></th>
                <th class="h">Info</th>
                <th class="h">Organism</th>
                <th class="h">Definition</th>
              </tr>)
  end

  def sequence_rows
    tolimg = '<img src="/images/icon-zoom-14-smudged.gif" alt="[?]"/>'
    gbimg  = '<img src="/images/genbank.gif" alt="[GB]">'
    gb_anchor_start = '<a target="_blank" href="http://www.ncbi.nlm.nih.gov/nuccore/'
    tol_anchor_start = '<a target="_blank" href="/projects/' + current_project.project_id.to_s + '/molecular/sequences/'
    rows = '<tbody id="cell_sequences_list">'
        @alignment.sequences.each do |seq|
          #seq = Molecular::Insd::Seq.where('pk = ?', a_seq.seq_id).first
          #debugger
          rows += %(
            <tr id="tr_sequence_#{seq.id}" class="#{cycle('body-odd', 'body-even')}" data-seq-id="#{seq.id}" data-tooltip="#{seq.sequence}">
              <td class="b tdseq">
                #{ link_to image_tag("x.png", :border=>0),
                           remove_sequence_project_molecular_alignment_path(:project_id => params[:project_id], :id => @alignment.id, :seq_id => seq.id ),
                           :method => :put,
                           :confirm => 'Are you sure you would like to remove this sequence?' }
              </td>
              <td class="b tdseq">#{ (seq.locus.nil? || seq.locus == "") ? '' : (gb_anchor_start + seq.locus + '" title="genbank">' + gbimg + "</a>") } #{ tol_anchor_start + seq.id.to_s + '" title="view">' + tolimg + '</a>'}</td>
              <td class="b tdseq">#{seq.organism.to_s}</td>
              <td class="b tdseq"><div class='overflow_ellipsis'>#{seq.definition.to_s}</div></td>
            </tr>
          )
        end
        return rows + '</tbody>'
  end

  def action_button action
    case action
      when 'select'
        text, img = 'Select text', '/images/copy.png'
      when 'export'
        text, img = 'Export file', '/images/small_import.png'
      when 'export_fasta'
        text, img = 'Export FASTA file', '/images/small_import.png'
      when 'export_clustal'
        text, img = 'Export CLUSTAL file', '/images/small_import.png'
      when 'show'
        text, img = 'Show and select Alignment text', '/images/small_search.png'
    end
    return %( <input class="button_img" tool="#{action}" type="button" style="background-image: url(#{img});" value="#{text}"> )
  end

  def action_list_id
    'viewport_molecular_alignments_user_panel_molecular_alignments_action_list'
  end
end
