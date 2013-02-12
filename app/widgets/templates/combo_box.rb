class Templates::ComboBox < Widget
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
    super
  end

  #FIXME: getting text, id values and such for html template can be done a lot simpler in-template than by these getters
  # at least one bug found related to this 04/27/2011

  def name
    "#{model_object.class.to_s.demodulize.underscore}[#{[*attribute_path].first.singularize}_id][]"
  end

  def value_label
    (value && truncate(value.send(text_method), length: (width+20)/8)) || ''
  end

  def value_fulltext
    (value && ((value.respond_to?(value_method) && value.send(value_method)) || value[text_method])) || ''
  end

  def value_searchtext
    (value && ((value.respond_to?(value_method) && value.send(value_method)) || value[search_method])) || ''
  end

  def value_id
    value && ((value.respond_to?(value_method) && value.send(value_method)) || value[value_method])
  end

  def value
    [ attribute_path ].flatten.inject(model_object) { |obj, method_part| obj.send(method_part) }
  end

  def box_style
    "width: #{width}px"
  end

  def to_s
    render_to_string
  end

  def render_to_string
    case interact_mode.to_s
    when 'browse'
      if !value || value.send(text_method).strip == ''
        "<span class='empty'>None</span>"
      else
        "<span class='link' data-id='#{value.send(value_method)}'>#{value.send(text_method)}</span>"
      end
    when 'edit'
      render partial: 'widgets/combo_box'
    end
  end
end