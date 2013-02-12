class Molecular::DnaSamples::CollectionComboBox < Templates::ComboBox
  def initialize options
    @dna_sample ||= options[:dna_sample] || fail('dna sample not given')
    @model_object = @dna_sample
    @attribute_path = 'collection'
    @value_method = 'id'
    @text_method = 'label'
    @search_method = 'collector'
    super
  end

  def value_searchtext
    #(value && ((value.respond_to?(value_method) && value.send(value_method)) || value[search_method])) || ''
    @dna_sample.try('collection').try('collector') || ''
  end

  def value_fulltext
    #(value && ((value.respond_to?(value_method) && value.send(value_method)) || value[search_method])) || ''
    @dna_sample.try('collection').try('collector') || ''
  end
end