class Collections::ElevationUnitComboBox < Templates::ComboBox
  def initialize options
    @collection ||= options[:collection] || fail('collection not given')
    @model_object = @collection
    @attribute_path = 'elevation_unit'
    @value_method = 'id'
    @text_method = 'label'
    @search_method = 'name'
    super
  end
end
