class Morphology::Matrices::MatrixNameAutoTextField < Templates::AutoTextField
  def initialize options
    @attribute_path ||= 'name'
    @value_method = 'name'
    @text_method = 'name'
    @width = 350
    @object_name ||= 'matrix'
    super
  end
end