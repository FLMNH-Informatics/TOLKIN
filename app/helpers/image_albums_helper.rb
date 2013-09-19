module ImageAlbumsHelper

  def get_image_data(file)
    send_data
  end

  def images_catalog
    ImageAlbums::Catalog.new({
        collection: @images,
        parent: content_frame
      }).render_to_string

  end

  def image_list_widget
    ImageAlbums::ImageList.new({
        context: self,
        images: @images,
        parent: content_frame })
  end

  def image_albums_action_panel
    Widgets::ImageAlbums::Catalogs::ActionPanel.new({
      parent: viewport
    })
  end

  def images
    @images
  end

  def options_for_search
    options = ""
    search_options.each do |option|
      options += %(<option value="#{option}" #{option == "taxon" ? %(disabled="disabled") : "" } >#{option.capitalize}</option>)
    end
    options
  end

  def search_options
    %w(taxon caption distribution photographer section subsection subgenus)
    #note: if you add more options, make sure to add where condition in image_albums_controller index method
  end

  def images
    ImageAlbums::ImageGallery.new({
      context: self,
      images: @images,
      parent: content_frame,
    }).render_to_string
  end
end
