module Molecular::MarkersDisplay

  def markers_table_add
    interact_mode == 'browse' ? '' : ('<tr><td colspan="4">' + new_marker_link + '</td></tr>')
  end

  def new_marker_link
    interact_mode == "browse" ? '' : '(<a class="toggle_marker_control">+new</a>)(<a class="toggle_marker_control">+existing</a>)'
  end

  def markers_table_header
    return %(<thead>
      <tr>
        <th class="h"></th>
        <th class="h">Name</th>
        <th class="h">Type</th>
        <th class="h">Start position</th>
        <th class="h">End position</th>
      </tr>
    </thead>)
  end

  def markers_table_rows
    #new table rows using start_position and end position
    rows = ''
    if @seq.class == Molecular::Insd::Seq
      #@seq.seq_markers.sort{|a,b| a.start_position <=> b.start_position unless (a.start_position.nil? || b.start_position.nil? || a.start_position.blank? || b.start_position.blank?) }.each do |sm|
      @seq.seq_markers.each do |sm|
        rows += %(
          <tr id="tr_sm_#{sm.id}" class="#{cycle('body-odd', 'body-even')}" data-sm_id="#{sm.id}">
            <td class="b td_seq_markers">#{interact_mode == 'edit' ? %(<a class="remove_marker_from_seq"><img src="/images/16-em-cross.png" alt="remove" /></a>) : ''}</td>
            <td class="b td_seq_markers">#{ (sm.marker and sm.marker.name)  ? sm.marker.name    : ''   }</td>
            <td class="b td_seq_markers">#{ (sm.marker and sm.marker.type)  ? sm.marker.type    : 'n/a'}</td>
            <td class="b td_seq_markers">#{  sm.start_position              ? sm.start_position : 'n/a'}</td>
            <td class="b td_seq_markers">#{  sm.end_position                ? sm.end_position   : 'n/a'}</td>
          </tr>
        )
      end
    end
    return rows
  end

end