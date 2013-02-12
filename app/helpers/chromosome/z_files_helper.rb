module Chromosome::ZFilesHelper

  def z_file_download_link
    @z_file.zvi_file_name + %(&nbsp;(<a href="#{@z_file.zvi_file}" title="download Z file">download</a>))
  end

  #def add_dye_control
  #  out = %{<span id="add_dye_control" style="display:none;">}
  #  out << %{&nbsp; Dye value:<input type="text" name="dye[dye_value]" id="dye_dye_value" /><input type="button" id="add_dye" value="Add dye" />}
  #  out << %{</span>}
  #end

  def display_images
    #todo after migrations change to images not zimages and possibly refactor since this same code is used elsewhere
    out = %{<table><tbody>}
    @z_file.zimages.each_slice(6) do |group|
      out << '<tr>'
      group.each do |img|
        out << %{<td id="image_#{img.id.to_s}">}
        out << %{#{zimage img}}
        out << "</td>"
      end
      out << "</tr>"
    end
    out << "<tr><td>no images attached</td></tr>" if @z_file.zimages.nil? || @z_file.zimages.empty?
    out << "</tbody></table>"
    out
  end

  def zimage img
    reduction_factor = img.height / 60
    thumb_width = img.width / reduction_factor
    out = %{<div class="img_holder" style="position:relative;width:#{thumb_width}px;height:60px">}
    out << %{<img data-image-id="#{img.id}" src="#{img.attachment.url.sub('original','thumb')}" style="padding:2px;"/>}
    out << %{</br>}
    out << %{(<a title="view full sized image" href="#{img.attachment.url}" target="_blank">full&#8599;</a>)}
    out << %{<span style="position:absolute;left:#{thumb_width - 19}px;" title="remove image">(<a title="remove image" class="remove_image" data-zfile-id="#{@z_file.id.to_s}" data-img-id="#{img.id}">&times;</a>)</span>}
    out << "</div>"
    out
  end

  def viewport_window
    @viewport_window ||= General::Window.new
  end

  def probe_catalog
    Chromosome::Probes::ProbeCatalog.new({
      collection: @probes,
      context: self,
      parent: viewport_window,
      can_publify: false
    }).render_to_string
  end

  def z_files_catalog
    Chromosome::ZFiles::Catalog.new({
        collection: @z_files,
        parent: content_frame
      }).render_to_string
  end

end