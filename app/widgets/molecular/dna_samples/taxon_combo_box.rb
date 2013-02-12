class Molecular::DnaSamples::TaxonComboBox < Templates::ComboBox
  def initialize options
    @dna_sample ||= options[:dna_sample] || fail('dna sample not given')
    @model_object = @dna_sample
    @attribute_path = 'taxon'
    @value_method = 'taxon_id'
    @text_method = 'label'
    @search_method = 'name'
    @width = 325
    super
  end

  def value_searchtext
    #(value && ((value.respond_to?(value_method) && value.send(value_method)) || value[search_method])) || ''
    
    @dna_sample.try('taxon').try('name') || ''
  end

  def value_fulltext
    
    #(value && ((value.respond_to?(value_method) && value.send(value_method)) || value[search_method])) || ''
    @dna_sample.try('taxon').try('name') || ''
  end
end
