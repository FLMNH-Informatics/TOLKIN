class Library::Citations::AuthorNameAutoTextField < Templates::AutoTextField
  def initialize options
    @attribute_path ||= 'author'
    @value_method = 'id'
    @text_method = 'name'
    @width = 275
    @object_name ||= 'citation'
    super
  end
end

