module SeqSearch
  module MolMatrixGenbankSearch
    include SeqSearch::GenbankInterpreter

    def make_table gb_records
      seqs = assemble_seqs(gb_records)
      #unless gb_records['GBSet']['Error']
      #  seqs = assemble_seqs(gb_records, check_type(gb_records))
      html_to_render = begin_table + table_rows(seqs) + end_table + table_bottom #add 1 to @start to switch from index to position
      return [html_to_render, seqs]
      #else
      #  return gb_records['GBSet']['Error']
      #end
    end

    def make_seq genbank_seq
      seq = current_project.sequences.new()
      seq.attributes.each{|k,v| seq[k] = genbank_seq[k] if genbank_seq.has_key?(k) }
      return seq
    end

    def process_marker(gb_seq)
      if current_project.markers.where('type = ? and lower_name = ?', gb_seq["type"], gb_seq["name"].downcase).empty?
        @count_marker = @count_marker + 1 if @current_marker
        mrkr = current_project.markers.new
        mrkr.attributes.each{|k,v| mrkr[k] = gb_seq[k] if gb_seq.has_key?(k)}
        mrkr.save!
        return { mrkr => gb_seq["position"] }
      else
        return { current_project.markers.where('type = ? and lower_name = ?', gb_seq["type"], gb_seq["name"].downcase).first => gb_seq["position"] }
      end
    end

    def add_seq_from_genbank_results
      %(<input id="add_genbank_seq" class="btn_image_cel btn_add_genbank_seq" type="button" style="height: 25px; margin-left: 5px; display: none;" value="    Add" tool="add_genbank">)
    end

    def sort_img
      #no longer needed because ncbi is handling the sorting
      #%(<span class="goright"><img tool="sort" src="/images/sort_incr_13.png" alt="[sort]" /></span>)

    end

    def th width
      %(<th class="trnopoint attribute_name"><div class="posrel" style="width: #{width}px;">)
    end

    def table_header
      th = ""
      th << '<div class="header"><table><tbody><tr><th class="trnopoint"><div><input tool="check_all" class="check_all" type="checkbox"></div></th>'
      th << %(#{th '128'}Organism#{sort_img}</div></th>)     if @columns.include?('Organism')
      th << %(#{th '28'}Info</div></th>)                     if @columns.include?('Link')
      th << %(#{th '78'}Locus#{sort_img}</div></th>)         if @columns.include?('Locus')
      th << %(#{th '119'}Markers#{sort_img}</div></th>)      if @columns.include?('Marker')
      th << %(#{th '358'}Definition#{sort_img}</div></th>)   if @columns.include?('Definition')
      th << %(#{th '358'}Sequence#{sort_img}</div></th>)     if @columns.include?('Sequence')
      th << '</tr></tbody></table></div>'
      return th
    end

    def begin_table
      %(<div class="catalog-contents"><table><tbody>)
    end

    def end_table
      %(</tbody></table></div>)
    end

    def pagination_controls active
      active ? '' : 'inactive'
    end

    def table_bottom
      nonindexed_start = @start + 1
      footer = ""
      footer << %(<div class="catalog-footer">)
      footer << %(<table style="width: 100%" class="nav_elements navigation">)
      footer << %(<tbody><tr><td>)
      footer << %(<div class="border">)
      footer << %(<span tool="beginning" class="control #{pagination_controls(nonindexed_start != 1) }">)
      footer << %(|&lt;</span>&nbsp;&nbsp;<span tool="step_back" class="control #{pagination_controls(nonindexed_start != 1) }">)
      footer << %(&lt;&lt;</span>&nbsp;#{nonindexed_start} - #{ @start + @limit} of #{@count}&nbsp;)
      footer << %(<span tool="step_forward" class="control #{ pagination_controls( (nonindexed_start+@limit) < @count) }">)
      footer << %(&gt;&gt;</span>&nbsp;&nbsp;<span tool="end" class="control #{ pagination_controls( (nonindexed_start+@limit) < @count) }">&gt;|</span>)
      footer << %(</div></td></tr></tbody></table></div>)
      return footer
    end

    def check_type(gb_records)
      return gb_records['GBSet'].nil? ? 'fasta' : 'gbset'
    end

    def td(width, display, options={})
      !display.nil? ?
      %(<td style="" #{options unless options.empty?}><div title="#{display.tooltipify unless display.start_with?('<')}" class="" style="width: #{width}px;">#{display}</div></td>) :
        %(<td style=""><div></div></td>)
    end

    def gb_img_link(locus)
      %(<a target="_blank" href="http://www.ncbi.nlm.nih.gov/nuccore/#{locus}"><img class="gb_hov" src="/images/genbank.gif" alt="[GB]"/></a>)
    end

    def table_rows(seqs)
      rows = ""
      seqs[0..(@limit - 1)].each_with_index do |seq, index|
        rows << %(<tr class="trnopoint sortable row #{index.even? ? "even" : "odd"}" data-id="new_#{index.to_s}">)
        rows << %(<td><div class="checkbox_cell"><input tool="seq_check" type="checkbox" value="new_#{index.to_s}"></div></td>)
        rows << %(#{td '120',seq[:organism] })                                if @columns.include?('Organism')
        rows << %(#{td '20', gb_img_link(seq[:locus]), 'class="tdcenter"'})   if @columns.include?('Link')
        rows << %(#{td '70',seq[:locus]})                                     if @columns.include?('Locus')
        rows << %(#{td '110', seq[:markers].collect{|mrk| mrk[:name]}.join(', ') })              if @columns.include?('Marker')
        rows << %(#{td '350',seq[:definition] })                              if @columns.include?('Definition')
        rows << %(#{td '350', seq[:sequence].upcase })                        if @columns.include?('Sequence')
        rows << %(</tr>)
      end
      return rows
    end
  end
end