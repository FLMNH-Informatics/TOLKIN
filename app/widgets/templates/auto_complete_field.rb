class Templates::AutoCompleteField < Widget
  attr_reader :attribute_path,
              :model_object,
              :text_method,
              :value_method,
              :search_method,
              :id_number,
              :width

  def initialize options
    @attribute_path ||= options[:attribute_path]
    @text_method    ||= options[:text_method] || fail('text method required')
    @value_method   ||= options[:value_method]
    @search_method  ||= options[:search_method] || @text_method
    @model_object   ||= options[:model_object]
    @id_number      ||= options[:id_number]
    @width          ||= options[:width] || 220
    @object_name    ||= model_object.class.to_s.demodulize.underscore
    super
  end

  def text_field_style
    "width:#{@width-40}px"
  end

  def text_field_id
    "#{id}_text_field"
  end

  def text_field_value
    value_text || ''
  end

  def name
    "#{@object_name}[#{[*attribute_path].first.to_s.singularize}_#{@value_method}]"
  end

  def text_field_name
    "#{@object_name}[#{[*attribute_path].first.to_s.singularize}_#{@text_method}]"
  end

  def text_field_input_id
     "#{@object_name}_#{[*attribute_path].first.to_s.singularize}_#{@text_method}_auto_input"
  end

  def value_label
    value && truncate(value[text_method], length: (width+20)/8)
  end

  def value_text
    value && value[text_method]
  end

#   def value_searchtext
#     value && value[search_method]
#   end

  def value_id
    (value && value[value_method]) 
  end

  def value
    [ attribute_path ].flatten.inject(model_object) { |obj, method_part| obj.send(method_part.to_sym) }
  end

#   def box_style
#     "width: #{width}px"
#   end

  def to_s
    render_to_string
  end

  def render_to_string
    
    case context.interact_mode.to_s
    when 'browse'
      if !value || value[text_method].strip == ''
        "<span class='empty'>None</span>"
      else
        "<span class='link' data-id='#{value[value_method]}'>#{value[text_method]}</span>"
      end
    when 'edit'
      render partial: 'widgets/auto_complete_field'
    end
  end
end
