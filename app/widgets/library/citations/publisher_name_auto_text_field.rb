class Library::Citations::PublisherNameAutoTextField < Templates::AutoTextField
  def initialize options
    @attribute_path ||= 'publisher'
    @value_method = 'id'
    @text_method = 'name'
    @width = 275
    @object_name ||= 'citation'
    super
  end
end

