class Molecular::Primers::MarkerAutoCompleteField < Templates::AutoCompleteField
  def initialize options
    @primer ||= options[:primer] || fail('primer not given')
    @model_object ||= @primer
    @attribute_path ||= 'marker'
    @value_method = 'id'
    @text_method = 'name'
    @width = 275
    super
  end
end

