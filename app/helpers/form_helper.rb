module FormHelper
  def text_field(object_name, method, options = {})
    width = options.delete(:width)
    options[:style] = "width: #{width}px; #{options[:style]||''}" if width
    super object_name, method, options
  end
end
