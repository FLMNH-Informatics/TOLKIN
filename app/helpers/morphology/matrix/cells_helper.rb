module Morphology::Matrix::CellsHelper
  def states_checkbox_list
    @character.states.inject(''){|memo,state|
      memo << %(<label for="#{state.name}">
                  <input id="#{state.name}" #{interact_mode == 'browse' || params["action"] == "show_cell_info" ? 'disabled="true"' : ""} name="cell[state_codings][]" type="checkbox" #{@cell.state_codings.split(' ').include?(state.state) ? 'checked="true"' : '' unless @cell.state_codings.nil?} value="#{state.state}" title="#{state.description}" />
                  <span title="#{state.description}">#{state.state}: #{state.name}</span></label><br />)
    }
  end

  def display_images
    out = %{<table width="450px"><tbody>}
    @images.each_slice(3) do |group|
      group.each do |img|
        if group[0] == img
          out << %{<tr width="440px">}
        end
        out << %{<td id="image_#{img.id}" style="vertical-align:baseline;"><div class="img_holder" style="position:relative;width:107px;height:60px">}
        out << cell_image(img)
        out << "</div></td>"
      end
      out << "</tr>"
    end
    out << "<tr><td>no images attached</td></tr>" if @images.nil? || @images.empty?
    out << "</tbody></table>"
  end

  def cell_image(img)
    shouldnt_display = (interact_mode == 'browse' || params['action'] == 'new' || params[:action] == 'show_cell_info')
    out = %{<img data-image-id="#{img.id}" src="#{img.attachment.url.sub('original','thumb')}" style="padding:2px;"/>}
    out << %{</br>}
    ##not using this because no good edit page at this time(may need to edit photographer information etc)
    #out << %{(<a data-image-id="#{img.id}" title="edit image" class="show_image" data-img-id="#{img.id}">edit</a>)} unless shouldnt_display
    out << %{(<a title="view full sized image" href="#{img.attachment.url}" target="_blank">full&#8599;</a>)}
    out << %{<span style="position:absolute;right:0px;" title="remove image from cell">(<a title="remove image from cell" class="remove_image_from_cell" data-img-id="#{img.id}">&times;</a>)</span>} unless shouldnt_display
    out
  end

  def otu_link(otu)
    link_to otu.name, url_for(:controller => '/otus', :action => 'show', :project_id => @project.id, :matrix_id => @timeline.id, :id => otu.id)
  end

  def display_cell_citations
    out = ""
    unless @cell.citations.empty?
      @cell.citations.each do |citation|
        out << %{<div class="citation cell_citation" data-cell-id="#{@cell.id}" data-citation-id="#{citation.id}">}
        if interact_mode == 'edit' && params['action'] != 'show_cell_info' && params['action'] != 'new'
          out << %{<div class="buttons #{buttons_classes}">}
          out << %{<button class="citation_edit" data-citation-id="#{citation.id}" value="Edit">Edit</button><button data-citation-id="#{citation.id}" class="citation_remove" value="Remove">Remove</button>}
          out << %{</div>}
        end
        out << %{<p class='citation'>#{citation.display_name}</p></div>}
      end
    else
      out << "no citations attached"
    end
    out
  end

  def buttons_classes
    interact_mode == 'edit' ? ' active' : ''
  end

end