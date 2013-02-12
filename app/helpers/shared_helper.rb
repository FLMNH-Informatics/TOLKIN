module SharedHelper
  def generate_url(obj,project_id,others = {})
    if(!obj.new_record?)
      if obj.is_a?(Morphology::ChrState)
        citation_add_project_character_chr_state_path(project_id,obj.character_id,obj.id)
      elsif obj.is_a?(Morphology::StateCoding)
        add_citations_state_codings_project_morphology_matrices_path(project_id)#update_state_codings_path(project_id, obj.matrix_id,obj.otu_id, obj.character_id)
      else
        eval("citation_add_project_#{obj.class.to_s.demodulize.tableize.singularize.downcase}_path(#{params[:project_id]},#{obj.id})")
      end
    else
      citation_add_project_library_citations_path(project_id)
    end
  end
  
  def generate_javacript_for_list_items(js_array)
    js = ""
    js_array.each do |script|
      if(defined? script)
        js << self.send(script)
      else
        js << script
      end
      js << ";"
    end
    js
  end

  #  checks for if each of the selected list items is there in the index listing,
  #  if it finds the element it selects the check box and sets the class to highligth it
  def select_and_highlight_selected_items
    function ="function(element){"
    function << "if($('item_select_'+element.value) != null){"
    function << "$('item_select_'+element.value).checked = true;"
    function << "add_selected_class($('list_item_'+element.value));"
    function << "}" #end if
    function << "}" #end of function

    script = "var sel_list_items = $('sel_list').select('input[name=\"sel_items[]\"]');"
    script << "if(sel_list_items.size() > 0){"
    script << "sel_list_items.each( #{function} );"
    script << "};"
  end

  # Returns a value for the <i>attribute</i> for the given <i>object</i>.  Two extra types of formatting
  # will be performed extra parameters are provided in display properties.
  #
  # If a <tt>:display_attribute</tt>
  # is provided, the value that will be returned will be the sub-attribute of the given <i>attribute</i>
  # that has the provided <tt>:display_attribute</tt> as a name.  Thus text can be properly returned if the
  # <i>attribute</i> given is an object.
  #
  # If a <tt>:link_type</tt> is provided, the attribute value will either
  # link to another page or execute a provided javascript block.  <tt>:link_type</tt> is specified as either
  # 'javascript' or 'href'.
  #
  # <tt>:truncate</tt> will limit the length of the value returned to the specified limit
  #
  # If 'href', the link location is specified as <tt>:link</tt>, which can be either an
  # absolute path string or a rails path string that will be evaluated at runtime.
  #
  # If 'js', the javascript code
  # to execute is given as <tt>:link_function</tt>.  If the javascript requires any ruby variables to run, those
  # variables are provided in <tt>:link_params</tt> as strings.  They will be evaluated and entered into the
  # javascript function wherever a '?' is given.
  def list_attribute_tag(object, attribute, display_properties = { })
    # output either the given attribute or a sub-attribute
    if display_properties[:display_attribute]
      if object.send(attribute)
        # if multiple display attributes given concatenate them with a space in between
        display = ''
        [*object.send(attribute)].each do |list_item|
          [*display_properties[:display_attribute]].each do |display_item|
            if display_properties[:link] && display_properties[:link].kind_of?(Hash)
              #debugger if list_item.nil?
              display << link_to(list_item.send(display_item) , display_properties[:link].merge({ :id => list_item }))
            else
              display << "#{list_item.send(display_item)} "
            end
          end
          display.strip!
          display << ", "
        end
        display.slice!(display.size-2..display.size)

      else
        display = nil
      end
    else
      display = object.send(attribute)
    end

    # truncate result if requested
    display = truncate(display, :length => display_properties[:truncate]) if (display_properties[:truncate])

    # wrap output in link if standard link given
    if(display_properties[:link] && display_properties[:link_type] == 'href')
      display = "<a href='#{eval(display_properties[:link])}'>#{display}</a>" if display # avoid null values when taxon absent
    end

    # wrap output in link if javascript link given
    if(display_properties[:link_type] == 'js' && display_properties[:link_function] && display_properties[:link_params])
      evaluated_params = [ ]
      [*display_properties[:link_params]].each do | param |
        evaluated_params << eval(param).to_s
      end

      filled_link_function = display_properties[:link_function].gsub(/\?/) {
        evaluated_params.shift
      }

      display = "<span class='linkText'>#{display}</span>"
      display = "<td class='b' onclick=\"#{filled_link_function}\">#{display}</td>"
    else
      display = "<td class='b'>#{display}</td>"
    end

    display
  end
end
