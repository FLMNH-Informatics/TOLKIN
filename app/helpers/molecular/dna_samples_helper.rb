module Molecular::DnaSamplesHelper
  def action_list_id
    'molecular_dna_samples_action_list'
  end


  def dna_samples_window
    @dna_samples_window ||= Molecular::DnaSamples::Window.new( context: self, parent: viewport && @viewport )
  end

  def viewport_window
    @viewport_window ||= Templates::Window.new( context: self, parent: viewport && @viewport)
  end

  def taxon_combo_box
#    if(params[:action] == 'new' )
      parent = viewport_window
#    elsif(request.format.js?)
#      parent = dna_samples_window
#    else
#      parent = content_frame
#    end
    @taxon_combo_box ||= Molecular::DnaSamples::TaxonComboBox.new( context: self, parent: parent, dna_sample: @dna_sample )
  end

  def collection_combo_box
#    if(params[:action] == 'new' )
      parent = viewport_window
#    elsif(request.format.js?)
#      parent = dna_samples_window
#    else
#      parent = content_frame
#    end
    @colllection_combo_box ||= Molecular::DnaSamples::CollectionComboBox.new( context: self, parent: parent, dna_sample: @dna_sample )
  end


  def taxon_combo_box_id
    taxon_combo_box.id
  end

  def collection_combo_box_id
    collection_combo_box.id
  end

  def dna_samples_catalog
    Molecular::DnaSamples::Catalog.new(
        collection: @dna_samples,
        context: self,
        parent: content_frame
    ).render_to_string
  end

  def content_frame
    @content_frame ||= General::ContentFrame.new({ parent: viewport, context: self })
  end
  #
  #  def taxon_combo_box
  #    Widgets::Molecular::DnaSamples::TaxonComboBox.new({
  #      dna_sample: @dna_sample,
  #      context: self,
  #      parent: content_frame
  #    }).render_to_string
  #  end
  #
  #  def collection_combo_box
  #    Widgets::Molecular::DnaSamples::CollectionComboBox.new({
  #      dna_sample: @dna_sample,
  #      context: self,
  #      parent: content_frame
  #    }).render_to_string
  #  end


end
