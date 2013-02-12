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
        <th class="h">Position</th>
      </tr>
    </thead>)
  end

  def markers_table_rows
    rows = ''
    if @seq.class == Molecular::Insd::Seq
      @seq.seq_markers.sort { |a,b|
        if !a.position.blank? and !b.position.blank?
          if a.position.split('..').first.include?('<')
            if b.position.split('..').first.include?('<')
              a.position.split('..').first.tr('<','').to_i <=> b.position.split('..').first.tr('<','').to_i
            else
              a.position.split('..').first.tr('<','').to_i <=> b.position.split('..').first.to_i
            end
          else
            a.position.split('..').first.to_i <=> b.position.split('..').first.to_i
          end
        elsif !a.position.blank? and b.position.blank?
          a.position.split('..').first.tr('<','') <=> b.marker.name
        elsif !b.position.blank? and a.position.blank?
          a.marker.name <=> b.position.split('..').first.tr('<','')
        else
          a.marker.name <=> b.marker.name
        end
      }.each do |sm|
        rows += %(
          <tr id="tr_sm_#{sm.id}" class="#{cycle('body-odd', 'body-even')}" sm_id="#{sm.id}">
            <td class="b td_seq_markers"><a class="remove_marker_from_seq"><img src="/images/16-em-cross.png" alt="remove" /></a></td>
            <td class="b td_seq_markers">#{ (sm.marker and sm.marker.name)  ? sm.marker.name : ''   }</td>
            <td class="b td_seq_markers">#{ (sm.marker and sm.marker.type)  ? sm.marker.type : 'n/a'}</td>
            <td class="b td_seq_markers">#{  sm.position                    ? sm.position    : 'n/a'}</td>
          </tr>
        )
      end
    end
    return rows
  end

end