class Molecular::Matrices::OtuNameAutoTextField < Templates::AutoTextField
  def initialize options
    @attribute_path ||= 'name'
    @value_method = 'name'
    @text_method = 'name'
    @width = 275
    @object_name ||= 'otu'
    super
  end
end