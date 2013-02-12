require 'morphology/characters/catalog'
module Morphology::CharactersHelper

  def display_character_citations
    out = ""
    unless @character.citations.empty?
      @character.citations.each do |citation|
        out << %{<div class="citation character_citation" data-character-id="#{@character.id}" data-citation-id="#{citation.id}">}
        if interact_mode == 'edit' && params['action'] != 'show_character_info' && params['action'] != 'new'
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

  def action_list_id
    'morphology_character_action_list'
  end

  def action_list_title
    "Matrices using this"
  end

  def display_images
    out = %{<table><tbody>}
    @character.images.each_slice(6) do |group|
      group.each do |img|
        if group[0] == img
          out << %{<tr width="440px">}
        end
        out << %{<td id="image_#{img.id}" style="vertical-align:baseline;width:160px">}
        out << character_image(img)
        out << "</td>"
      end
      out << "</tr>"
    end
    out << "<tr><td>no images attached</td></tr>" if @character.images.nil? || @character.images.empty?
    out << "</tbody></table>"
  end

  def character_image(img)
    reduction_factor = img.height / 60
    thumb_width = img.width / reduction_factor
    out = %{<div class="img_holder" style="position:relative;width:#{thumb_width}px;height:60px">}
    out << %{<img data-image-id="#{img.id}" src="#{img.attachment.url.sub('original','thumb')}" style="padding:2px;"/>}
    out << %{</br>}
    ##not using this because no good edit page at this time(may need to edit photographer information etc)
    #out << %{(<a data-image-id="#{img.id}" title="edit image" class="show_image" data-img-id="#{img.id}">edit</a>)} unless shouldnt_display
    out << %{(<a title="view full sized image" href="#{img.attachment.url}" target="_blank">full&#8599;</a>)}
    out << %{<span style="position:absolute;left:#{thumb_width - 19}px;" title="remove image from character">(<a title="remove image from character" class="remove_image_from_character" data-character-id="#{@character.id}" data-img-id="#{img.id}">&times;</a>)</span>}
    out << "</div>"
    out
  end

  def chr_state_buttons(state)
    out = %{<span class="buttons #{buttons_classes}">}
    out << %{<button class="character_chr_state_edit" data-character-id="#{state.character.id}" data-chr-state-id="#{state.id}" value="Edit">Edit</button><button data-character-id="#{state.character.id}"data-chr-state-id="#{state.id}" class="character_chr_state_remove" value="Remove">Remove</button>}
    out << %{</span>}
    out
  end


  def display_chr_state_images(state)
    out = %{<table><tbody>}
    state.images.each_slice(2) do |group|
      group.each do |img|
        if group[0] == img
          out << %{<tr width="440px">}
        end
        out << %{<td id="chr_state_image_#{img.id}" style="vertical-align:baseline;width:160px">}
        out << chr_state_image(img, state)
        out << "</td>"
      end
      out << "</tr>"
    end
    out << "<tr><td>no images attached</td></tr>" if state.images.nil? || state.images.empty?
    out << "</tbody></table>"
  end

  def chr_state_image(img, state)
    reduction_factor = img.height / 60
    thumb_width = img.width / reduction_factor
    out = %{<div class="img_holder" style="position:relative;width:#{thumb_width}px;height:82px">}
    out << %{<img data-image-id="#{img.id}" src="#{img.attachment.url.sub('original','thumb')}" style="padding:2px;"/>}
    out << %{</br>}
    out << %{<a title="view full sized image" href="#{img.attachment.url}" target="_blank">full&#8599;</a>}
    out << %{<span style="position:absolute;left:#{thumb_width - 19}px;" title="remove image from character state"><a title="remove image from character" class="remove_image_from_chr_state" data-chr-state-id="#{state.id}" data-img-id="#{img.id}">(&times;)</a></span>}
    out << "</div>"
    out
  end

  def buttons_classes
    interact_mode == 'edit' ? ' active' : ''
  end

  def polarity_select
    "@polarity"
  end

  def characters_catalog
    Morphology::Characters::Catalog.new(
      collection: @characters,
      context: self,
      parent: content_frame
    ).render_to_string
  end

end
