module PublicationsHelper
  def publications_catalog
    Library::Publications::Catalog.new({
        collection: @collection,
        context: self,
        parent: content_frame
      }).render_to_string
    #       catalog('viewport_content_frame_citation_publication_catalog', @requested, [
    #        { :attribute => "name", :width => 250 },
    #      ], :count => @count
    #    )
  end

  def save_button
    case interact_mode
    when 'browse'
      'display:none'
    when 'edit'
      'display:block'
    end
  end

  def select_or_text (name=nil)
    case interact_mode
    when 'browse'
      'browseSelct'
    when 'edit'
      'editSelect'
    end
  end
end
