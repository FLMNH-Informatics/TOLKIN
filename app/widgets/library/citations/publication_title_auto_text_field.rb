class Library::Citations::PublicationTitleAutoTextField < Templates::AutoTextField
  def initialize options
    @attribute_path ||= 'publication_title'
    @value_method = 'id'
    @text_method = 'value'
    @width = 275
    @object_name ||= 'citation'
    super
  end
end
