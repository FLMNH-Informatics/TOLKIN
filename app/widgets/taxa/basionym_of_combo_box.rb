class Taxa::BasionymOfComboBox < Templates::ComboBox
  def initialize options
    @taxon ||= options[:taxon] || fail('taxon not given')
    @model_object = @taxon
    @attribute_path = 'basionym_of'
    @value_method = 'id'
    @text_method = 'label'
    super
  end
end