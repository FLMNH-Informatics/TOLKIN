class Collections::AnnotationsCatalogActionPanel < Templates::ActionPanel

  def initialize options
    @buttons = {}
    super
  end

  def to_s
    render partial: 'collections/annotations_catalog_action_panel'
  end

  def taxon_input_id
    (params[:id] || 'new') + '_annotations_taxon_input'
  end

  def deter_input_id
    (params[:id] || 'new') + '_annotations_determiner_input'
  end

  def date_input_id
    (params[:id] || 'new') + '_annotations_date_input'
  end

  def inst_input_id
    (params[:id] || 'new') + '_annotations_institution_input'
  end
  
end
