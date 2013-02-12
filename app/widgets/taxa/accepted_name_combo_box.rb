class Taxa::AcceptedNameComboBox < Templates::ComboBox
  def initialize options
    @taxon ||= options[:taxon] || fail('taxon not given')
    @model_object   = @taxon
    @attribute_path = 'accepted_name'
    @value_method   = 'taxon_id'
    @text_method    = 'label'
    @search_method  = 'name'
    @width          = 400
    super
  end
end