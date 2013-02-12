class Molecular::Primers::TaxonAutoCompleteField < Templates::AutoCompleteField
  def initialize options
    @primer ||= options[:primer] || fail('primer not given')
    @model_object ||= @primer
    @attribute_path ||= 'taxon'
    @value_method = 'rtid'
    @text_method = 'name'
    @width = 275
    super
  end
end

