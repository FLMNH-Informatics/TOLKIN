require 'recaptcha'
require 'viewport'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ReCaptcha::ViewHelper

  # Creates a submit button with the given name with a cancel link
  # Accepts two arguments: Form object and the cancel link name
  def submit_or_cancel(form, options = {})
    
    form.submit(options[:button_text] || 'Submit') + " or " + link_to(options[:back_link_text] || 'Cancel', 'javascript:history.go(-1);', :class => 'cancel')
  
  end

  #stupid helper helper to convert a hash into a JSON options list
  # (without the encompasing {}'s or any type of recursion
  #Is there a rails API function that does this?
  def jsonify hsh
    str = ''
    first = true
    hsh.each do |k,v|
      str += ', ' unless first
      str += "#{k}: "
      str += "'" unless (v.class == Fixnum or v.class == Float)
      str += v.to_s
      str += "'" unless (v.class == Fixnum or v.class == Float)
      first = false
    end
    str
  end

  def content_frame
    @content_frame ||= Widgets::Viewport::ContentFrame.new({ parent: viewport, context: self })
  end

  def viewport_id
    'viewport'
  end

  def page_header
    render partial: 'layouts/page_header'
  end

  def viewport
    @viewport ||= Viewport.new({ context: self })
  end

  def main_content_frame
    render partial: 'layouts/main_content_frame', locals: { parent_widget_id: viewport.id }
  end

  def google_maps_key
    case request.host
    when /((\w+)\.)?tolkin.org/, /localhost/
      %{ <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=false&amp;key=ABQIAAAAUaNOJMOKAjOKNlXRm9E9bBR2biOecEvk7hgPHQ9PerAKsDlMOxSCuzECXGNNhkz2wP3BIl3Ch3GjXQ" type="text/javascript"></script> }
    when /tolkin3.flmnh.ufl.edu/
      %{ <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=false&amp;key=ABQIAAAAUaNOJMOKAjOKNlXRm9E9bBQl0TvLnO9o9MfE6R4iTOweUgslrxQ0IqgjNfykGzpSUHDZHe6J5M7OVQ" type="text/javascript"></script> }
    when /tolkin-web-prod.flmnh.ufl.edu/
      %{ <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=false&amp;key=ABQIAAAAlqqLZi6FNV9R1_JSLDFAthR4y5lSHeUW9zIW5mGvouT9po6TNxSfHS2611JZ2ebUlp6Yy0mU0zfxhA" type="text/javascript"></script> }
    when /tolkin-web-dev.flmnh.ufl.edu/
      %{ <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=false&amp;key=ABQIAAAAlqqLZi6FNV9R1_JSLDFAthRnhWdyiQ-c-XCbjTuQUgr76p2ZDRTS9sAeSoS6mu6-3plliNgHoE2nGw" type="text/javascript"></script> }

    else ''
    end
  end

  def tags_cloud(tags, classes)
    return if tags.empty?
    max_count = tags.sort_by(&:count).last.count.to_f
    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end

  #customized method by srinivas for generating result list as per the tags specified like passing "a" for variable would result in the result list with hyperliks
  def auto_complete_result(entries, field, phrase = nil,tag=nil)
    return unless entries
    tag_type = "li"
    if !tag.nil?
      tag_type = tag
    end
    href= Hash.new
    items = entries.map do |entry|
      if !tag.nil?
        href[:href] = url_for(:controller=> "tag",:action=>"show",:id=>entry.id)
      end
      content_tag(tag_type, phrase ? highlight(entry[field], phrase) : h(entry[field]),href)
    end
    if tag_type == "a"
      items = items.map { |entry| content_tag("li",entry)}
    end
    content_tag("ul", items.uniq.join)
  end



  def window_head(title, element_id)
    result_str = '<div id="windowtitle" class="windowtitle" >'
    result_str << '<span class="title">' + title + '</span>'

    result_str << '<span id="closebutton" class ="closebutton" onClick="$(\'' + element_id + '\').hide();">'
    result_str << link_to("X", "javascript:void(0)")
    result_str << '</span></div>'
  end

  def pagination_links_remote(paginator)
    page_options = {:window_size => 1}
    pagination_links_each(paginator, page_options) do |n|
      options = {
        :url => {:action => 'list', :params => params.merge({:page => n})},
        :update => 'table',
        :before => "Element.show('spinner')",
        :success => "Element.hide('spinner')"
      }
      html_options = {:href => url_for(:action => 'list', :params => params.merge({:page => n}))}
      link_to_remote(n.to_s, options, html_options)
    end
  end

  def get_formatted_name(name, single_split)
    name_array = name.split("_")
    return_val = ""
    i= 0
    name_array.each { |n|

      if (i !=0 && i % 2 == 0) || (single_split == true)
        return_val = return_val + "<br/>"
      end
      return_val = return_val + n

      i = i+1
    }
    return raw return_val
  end

  def project_selected?
    session[:project_id]
  end

  def interaction_mode_switch
    @current_project && current_user != User.public_user ?
      %{
      <table id="viewport_content_frame_interact_mode_switch" class="widget switch">
        <tr>
          <td class="browse_option#{interact_mode == 'browse' ? ' selected' : ''}">Browse</td>
          <td class="edit_option#{interact_mode == 'edit' ? ' selected' : ''}">Edit</td>
        </tr>
      </table>
    } : ''
  end

  def project_license

    lic = PublicLicense.where(:id => current_project.public_license_id).first
    t = "<div style=\"font-size:10px; margin:5px auto\">This project's data is shared under the <a href=\"#{lic.url}\">#{lic.name}</a> license.</div>"
    raw t
  end

  private


  def generate_url(obj,project_id,others = {})
    if obj.is_a?(ChrState)
      citation_add_project_character_chr_state_path(project_id,obj.character_id,obj.id)
    else
      eval("citation_add_project_#{obj.class.to_s.demodulize.tableize.singularize.downcase}_path(#{params[:project_id]},#{obj.id})")
    end
  end

  def create_version_path(br_it_br, direction)
    case direction
    when :previous
      position = br_it_br.position - 1
    when :next
      position = br_it_br.position + 1
    end
    obj_id = br_it_br.branch.items.for_position(position).first.try(:item).try(:id)
    if !obj_id.nil?
      return  link_to(direction.to_s, url_for(:action => 'show', :project_id => @project.id, :id => obj_id) )#project_character_path(@project, obj_id)
    else
      return ""
    end
  end

  def optional_matrix_resource_url(link_params)
    controller.optional_matrix_resource_url(link_params)
  end

  def delete_citation_path
    url_for({:action => :delete_citation})
  end

  def citation_item_name(obj, citation)
    "#{obj.class.to_s.demodulize.downcase}_#{obj.id}_citation_#{citation.id}"
  end

  # old method for non-joose rjs driven javascript
  def get_citation_item_name(obj, citation_id)
    "#{obj.class.to_s.demodulize.downcase}_#{obj.id}_citation_#{citation_id}"
  end

  def interaction_mode_switch_position
    if(session['interaction_mode'] == 'browse')
      "top: 25px; left: 5px;"
    elsif(session['interaction_mode'] == 'edit')
      "top: 25px; left: 130px;"
    end
  end

  def change_item_rows
    out = ""
    (@changeset || @matrix.changeset).changes(:limit => 3).each do |change|
      out << "<li data-change-id='#{change.id}'>#{change.to_s} <a class='revert_change_link'>revert</a></li>"
    end
    out
  end

  def changes_start_position
    (@changeset || @matrix.changeset).changes(:limit => 3).try(:first).try(:position) || 1
  end
end
