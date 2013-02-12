class Collections::TaxonComboBox < Templates::ComboBox
  def initialize options
    @collection ||= options[:collection] || fail('taxon not given')
    @model_object = @collection
    @attribute_path = 'taxon'
    @value_method = 'taxon_id'
    @text_method = 'label'
    @search_method = 'name'
    @width = 475
    super
  end
end
