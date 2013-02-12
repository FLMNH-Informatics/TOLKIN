class Molecular::Primers::PurificationMethodAutoCompleteField < Templates::AutoCompleteField
  def initialize options
    @primer ||= options[:primer] || fail('primer not given')
    @model_object ||= @primer
    @attribute_path ||= 'purification_method'
    @value_method = 'id'
    @text_method = 'name'
    @width = 275
    super
  end
end

