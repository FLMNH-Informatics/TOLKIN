module FormsHelper

  def select_concat(object, project, methods, padding=("&".html_safe + "nbsp;".html_safe), *name)
    objects = project == 'all' ? object.all : object.for_project(project)
    methods = [*methods] #force to array
    leading_max = objects.inject(0){ |memo, obj| memo = obj.try(methods.first).length > memo ? obj.try(methods.first).length : memo }
    html_options = []
    objects.each do |obj|
      leading_item = obj.try(methods.first)
      last_item    = obj.try(methods.last)
      pads = leading_max - leading_item.length
      padding = padding || ("&".html_safe + "nbsp;".html_safe)
      display_name = leading_item + padding.html_safe * pads + padding*3
      if object.inspect.match(/(?<=#{last_item}:).+(?=,)/).to_s.strip == "datetime"
        display_name += (last_item.nil? ? '' : last_item.to_datetime.to_formatted_s(:long))
      else
        display_name += (last_item.nil? ? '' : last_item.to_s)
      end
      html_options.push([raw(display_name), obj.try(object.primary_key).to_s])
    end
    options = {:style => 'font-family:monospace;'}
    options.merge({:name => name}) unless name.nil?
    display_name = name.empty? ? object.table_name.singularize : name.first
    select(display_name, object.primary_key.to_s, html_options, {:include_blank => true}, options)
  end

  def general_window
    @general_window ||= General::Window.new
  end

  def auto_complete_field (object, method, options = {})
    Templates::AutoCompleteField.new(
      context: self,
      parent: options[:parent],
      attribute_path: method,
      model_object: object,
      text_method: object.class.auto_complete_text_method,
      value_method: object.class.primary_key,
      object_name: object.class.to_s.demodulize.underscore
    )
  end

  def combo_box(object, method, collection, options = {}, html_options = {})
    render :partial => 'widgets/combo_box', :locals => {
      :id => html_options[:id],
      :value_id => html_options[:id] || (object.respond_to?(method) && object.send(method) ? object.send(method).id : nil),
      :value_label => object.respond_to?(method) && object.send(method) ? object.send(method).label : nil,
      :name => html_options[:name] || (object.respond_to?(:underscore) ? "#{object.underscore}[#{method.to_s}]" : "#{object.class.to_s.split('::').pop.underscore}[#{method.to_s}]")
      #,:collection => collection,
      #:options => html_options
    }
  end

  def date_field(record, attribute, options = {})
    record.send(attribute).to_s =~ /(\d{4})\-(\d{2})\-(\d{2})/
    split_date = { Y: $1, mm: $2, dd: $3}
    def split_date.Y
      return self[:Y]
    end

    def split_date.mm
      return self[:mm]
    end

    def split_date.dd
      return self[:dd]
    end

    object_name = options[:form_builder] ? options[:form_builder].object_name : fail("can't get standard object name after rails 3 migration")
    #object_name = ActionController::RecordIdentifier.singular_class_name(record)
    temp=object_name.to_s.split('_')
    temp.slice!(0)
    object=""
    n=temp.length-1
    for i in 0..n
      object+=temp.slice!(0)
      if(i!=n)
        object+="_"
      end
    end
    render :partial => 'forms/date_field.html.haml', :locals => {
      :object_name => options[:object_name] ? options[:object_name] : object,
      :attribute_name => attribute,
      :date => split_date
    }
  end

  def edit_link_if_can_edit(attribute_name)
    if @can_edit
      return "<a class='toggle_edit_link' href='javascript:null(0)'>
                <img id='edit_#{attribute_name}_icon' src='/images/icon_edit.png' />
              </a>"
    else
      return ""
    end
  end

  def appropriate_editable_field_tag(item, attribute, update_url)
    options = {}
    options[:cols] = attribute[:cols] if attribute[:cols]
    options[:url] = update_url
    options[:link] = attribute[:link] if attribute[:link]

    out_tag = case attribute[:edit_type]
    when :custom        then render :partial => attribute[:partial], :object => attribute[:object], :layout => attribute[:layout]
    when :checkbox_list then editable_checkbox_list_tag           item, attribute[:names]
    when :collection    then editable_collection_tag              :span, item, attribute[:name], attribute[:enum_name_column], attribute[:enum_object].find(:all,:order=> attribute[:enum_name_column]), @can_edit, options
    when :autocomplete  then editable_field_tag_with_autocomplete :span, item, attribute[:name], attribute[:autocomplete_url] || auxsearch_path(params[:project_id],:id=>item.id), @can_edit, options
    else                     editable_content_tag                 :span, item, attribute[:name], @can_edit, options
    end
    out_tag
  end

  def editable_checkbox_list_tag(object, properties)
    result_str = "<span></span><span>"
    result_str << form_remote_tag(:url => update_others_project_collection_path(params[:project_id], object, :parameter=> :collection_check), :update => { :failure => "form_collection_check" }, :method => :put, :id=>"form_collection_check", :colspan=>"2")
    properties.each do | property |
      result_str << check_box(object.class.to_s.demodulize.downcase, property) + "<b>#{property.to_s.titleize} </b>"
    end
    result_str << submit_tag('save', :disabled=> !object.can_edit?(session[:user_id]))
    result_str << "</form></span>"
  end

  def editable_field_tag_with_autocomplete(elemtype, obj, prop, searchPath, editable, options = {}, editOptions = {}, ajaxOptions = {})
    objname = obj.class.to_s.demodulize.underscore
    options[:cols] = 20 if !options[:cols]
    options[:url] = "/#{objname.pluralize}/#{obj.id}" unless options.has_key? :url
    options[:url] += '.json'
    options[:id] = dom_id(obj)+"_#{prop}" unless options.has_key? :id
    ajaxOptions[:method] = 'put'
    edops = jsonify editOptions
    ajops = jsonify ajaxOptions

    # avoid null value
    if(obj.send(prop))
      current_value = obj.send(prop).name
    else
      current_value = ''
    end

    tg =  "<div id='#{options[:id]}'>#{current_value}</div>"
    tg << "<a href='#{options[:link]}'>link</a>" if options[:link]
    if editable then
      # divider for auto-complete results when they are returned
      tg << "<div id='#{options[:id]}_options' class='auto_complete' style='display: none' ></div>
             <script type='text/javascript'>
               var editor = new Ajax.InPlaceEditor('#{options[:id]}', '#{options[:url]}', {
                 cols: #{options[:cols]},
                 ajaxOptions: { #{ajops} },
                 callback: function(form, value) {
                   return 'authenticity_token=#{form_authenticity_token}&find_by_name=Taxon&#{objname}[#{prop}]=' + escape(value)
                 },
                 onComplete: function(transport, element) {
                   //element.href = transport.responseText.evalJSON().#{objname}.href;
                   element.innerHTML = transport.responseText.evalJSON().#{objname}.#{prop}.label;
                   this._checkEmpty();
                 },
                 onLeaveEditMode: function(form, value)
                 {
                   $('#{options[:id]}_options').setAttribute('style', 'display: none;');
                 }"
      tg << ",#{edops}" unless edops.empty?
      tg << "});\n
             Object.extend(editor, {
             _createEditField: editor.createEditField,
             createEditField: function() {
               this._createEditField();
               new Ajax.Autocompleter(this._controls.editor,'#{options[:id]}_options', '#{searchPath}',
                 { paramName: 'search',
                   method: 'get',
                   callback: function(form, value) {
                     return 'authenticity_token=#{form_authenticity_token}&variable=#{prop}&is_new_taxon=false&ajax_autocomplete=true&' + escape(value)
                   }
                 }
               );
             }
             }); </script>\n"
    end
    tg
  end

  def editable_content_tag(elemtype, obj, prop, editable, options = {}, editOptions = {}, ajaxOptions = {})
    objname = obj.class.to_s.demodulize.underscore
    options[:cols] = 20 if !options[:cols]
    options[:url] = "/#{objname.pluralize}/#{obj.id}" unless options.has_key? :url
    options[:url] += '.json'
    options[:id] = dom_id(obj)+"_#{prop}" unless options.has_key? :id
    ajaxOptions[:method] = 'put'
    edops = jsonify editOptions
    ajops = jsonify ajaxOptions

    tg = content_tag(elemtype, obj.send(prop), options = options)
    tg << "<a href='#{options[:link]}'>link</a>" if options[:link]
    if editable then
      tg << "
           <script type='text/javascript'>\n
               new Ajax.InPlaceEditor('#{options[:id]}', '#{options[:url]}', {
                        cols: #{options[:cols]},
                        ajaxOptions: { #{ajops} },
                        callback: function(form, value)
                          { return 'authenticity_token=#{form_authenticity_token}&#{objname}[#{prop}]=' + escape(value) },
                        onComplete: function(transport, element)
                          { element.innerHTML=transport.responseText.evalJSON().#{objname}.#{prop};
                            this._checkEmpty(); }"
      tg << ",#{edops}" unless edops.empty?
      tg << "});\n"
      tg << "         </script>\n"
    end
    tg
  end

  def editable_collection_tag(elemtype, obj, prop, display_column, collection, editable, options = {}, editOptions = {}, ajaxOptions = {})
    objname = obj.class.to_s.demodulize.underscore
    options[:cols] = 20 if !options[:cols]
    options[:url] = "/#{objname.pluralize}/#{obj.id}" unless options.has_key? :url
    options[:url] += '.json'
    options[:id] = dom_id(obj)+"_#{prop}_id" unless options.has_key? :id
    ajaxOptions[:method] = 'put'
    edops = jsonify editOptions
    ajops = jsonify ajaxOptions

    collection_string = collection.map{ |c| ["#{c.id}", c[display_column]]}.to_json

    # avoid null value
    if(obj.send(prop))
      current_value = obj.send(prop)[display_column]
    else
      current_value = nil
    end

    tg = content_tag(elemtype, current_value, options = options)
    if editable then
      tg += "
           <script type='text/javascript'>\n
               new Ajax.InPlaceCollectionEditor('#{options[:id]}', '#{options[:url]}?need_selection_name=true&enum_name_column=#{display_column}', {
                        cols: #{options[:cols]},
                        collection: #{collection_string},
                        ajaxOptions: { #{ajops} },
                        callback: function(form, value)
                          { return 'authenticity_token=#{form_authenticity_token}&#{objname}[#{prop}_id]=' + escape(value) },
                        onComplete: function(transport, element)
                          { element.innerHTML=transport.responseText.evalJSON().#{objname}.#{prop}_name;
                            this._checkEmpty();}"
      tg += ",#{edops}" unless edops.empty?
      tg += "});\n"
      tg += "         </script>\n"
    end
    tg
  end

  def editable_textarea(object, property, url, allow_edit, options = { })
    objname = object.class.to_s.demodulize.underscore
    options[:rows] = 8  if !options[:rows]
    options[:cols] = 20 if !options[:cols]

    name = "#{objname}_#{property.to_s}"

    # avoid null value
    if(object.send(property))
      current_value = object.send(property).to_s == "" ? "click to edit ..." : object.send(property).to_s
    else
      current_value =  "click to edit ..."#nil
    end

    response = "
    <form id='#{name}_form' action='#{url}'>
      <textarea id='#{name}_field' rows='#{options[:rows]}' cols='#{options[:cols]}' readonly='readonly'>#{current_value}</textarea>
    </form>
    <div id='#{name}_edit_controls' style='visibility: hidden'> \
      <input id='#{name}_ok' type='submit' value='ok' /> \
      <input id='#{name}_cancel' type='submit' value='cancel' /> \
    </div>
    "
    if allow_edit then
      response += %`
      <script type='text/javascript'>
        var origFieldContents = $F('#{name}_field') == '' ? "click to edit ..." : $F('#{name}_field');
        var contentsToSave = null;

        $('#{name}_field').observe('click', function(event) {
          if ($F('#{name}_field') == "click to edit ...") { $('#{name}_field').value = '' } ;
          $('#{name}_field').writeAttribute('readonly', false);
          $('#{name}_edit_controls').writeAttribute('style', 'visibility: visible');
        });

        $('#{name}_form').observe('submit', function(event) { event.stop() });

        $('#{name}_cancel').observe('click', function(event) {
          $('#{name}_edit_controls').writeAttribute('style', 'visibility: hidden');
          $('#{name}_field').value = origFieldContents;
          $('#{name}_field').writeAttribute('readonly', 'readonly');
        });

        $('#{name}_ok').observe('click', function(event) {
          new Ajax.Request('#{url}', {
            method: 'put',
            parameters : "authenticity_token=#{form_authenticity_token}&#{objname}[#{property.to_s}]=" + $F('#{name}_field'),
            onCreate : function(transport) {
              $('#{name}_edit_controls').writeAttribute('style', 'visibility: hidden');
              $('#{name}_field').writeAttribute('readonly', 'readonly');
              contentsToSave = $F('#{name}_field');
              $('#{name}_field').value = "saving ...";
            },
            onSuccess : function(transport) {
              origFieldContents = contentsToSave == '' ? "click to edit ..." : contentsToSave;
              $('#{name}_field').value = origFieldContents;
            },
            onFailure : function(transport) {
              $$('.notice_area').each(function(e) { e.update("<span class='status-msg'>" + transport.responseText + "</span>") });
              $('#{name}_field').value = origFieldContents;
            }
          });
        });
      </script>`
    end
    response
  end

  def text_field_or_text(detail,size=nil, html_options = {})
    width = html_options[:width] || 450;
    str=""
    if(interact_mode=="browse")
      str+=@taxon[detail].blank? ? "<span class='empty'>None</span>" : "<div style='width: #{width}px'>#{@taxon[detail]}</div>"
    else
      str+="<input type='text' #{size ? "size='#{size}'" : ''} value='#{@taxon[detail].blank? ? "" : @taxon[detail]}' name='taxon[#{detail}]'>"
    end
    str
  end

end
