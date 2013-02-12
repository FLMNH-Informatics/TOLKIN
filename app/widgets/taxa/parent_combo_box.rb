class Taxa::ParentComboBox < Templates::ComboBox
  def initialize options
    @taxon ||= options[:taxon] || fail('taxon not given')
    @model_object   = @taxon
    @attribute_path = 'parent'
    @value_method   = 'id'
    @text_method    = 'label'
    @search_method  = 'name'
    @width          = 400
    super
  end

  def name
    'taxon[parent_taxon_id][]'
  end
end