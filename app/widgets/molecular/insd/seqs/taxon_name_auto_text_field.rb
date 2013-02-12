class Molecular::Insd::Seqs::TaxonNameAutoTextField < Templates::AutoTextField
  def initialize options
    @attribute_path ||= 'taxon'
    @value_method = 'taxon_id'
    @text_method = 'name'
    @width = 275
    @object_name ||= 'molecular_insd_seq'
    super
  end
end