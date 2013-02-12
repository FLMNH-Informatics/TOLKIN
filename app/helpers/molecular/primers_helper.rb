module Molecular::PrimersHelper
#   def action_list_id
#     'viewport_molecular_primers_user_panel_molecular_primers_action_list'
#   end
  def taxon_combo_box
#    if(params[:action] == 'new' )
      parent = viewport_window
#    elsif(request.format.js?)
#      parent = dna_samples_window
#    else
#      parent = content_frame
#    end
    @taxon_combo_box ||= Molecular::Primers::TaxonComboBox.new( context: self, parent: parent, primer: @primer )
  end

  def submit_row_submit
      request.xhr? ? '' : "<tr><td><input type='submit' value='Update' name='submit'><td></tr>"
  end

  def gene_auto_text_field
    parent = viewport_window
    @gene_auto_text_field ||= Molecular::Primers::GeneAutoTextField.new( context: self, parent: parent, primer: @primer)
  end

  #TODO: PLEASE REPLACE THIS WITH TAXON AUTO TEXT FIELD
  def taxon_auto_complete_field(f)
    Molecular::Primers::TaxonAutoCompleteField.new({
      primer: f.object,
      parent: viewport_window,
      context: self
    })
  end

  def marker_new_or_current
    select("primer", "marker_id", [["Create new marker", "new"]]+(Molecular::Marker.for_project(current_project).sort{|a,b| a.name.downcase <=> b.name.downcase }.collect{ |m| [m.name, m.id] }), { :include_blank => true})
  end

  def purification_method_new_or_current
    select("primer", "purification_method_id", [["Create new method", "new"]]+(Molecular::PurificationMethod.for_project(current_project).sort{|a,b| a.name.dowcase <=> b.name.downcase }.collect{|pm| [pm.name, pm.id]}), {:include_blank => true})
  end

  def marker_auto_complete_field(f)
    Molecular::Primers::MarkerAutoCompleteField.new({
      primer: f.object,
      parent: viewport_window,
      context: self
    })
  end

  def purification_method_auto_complete_field(f)
    Molecular::Primers::PurificationMethodAutoCompleteField.new({
      primer: f.object,
      parent: viewport_window,
      context: self
    })
  end

  def viewport_window
    @viewport_window ||= General::Window.new
  end

  def primers_catalog
    Molecular::Primers::Catalog.new({
      collection: @primers,
      parent: content_frame
    }).render_to_string
  end
end
